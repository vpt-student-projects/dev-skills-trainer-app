using Docker.DotNet;
using Docker.DotNet.Models;
using System;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using SharpCompress.Archives.Tar;
using SharpCompress.Common;
using SharpCompress.Writers;

using System.Threading.Tasks;
using SharpCompress.Writers.Tar;

namespace worker
{
    

    public class SandboxManager
    {
        private readonly DockerClient _dockerClient;
        private readonly TimeSpan _containerCreationTimeout = TimeSpan.FromSeconds(30);
        private readonly TimeSpan _executionTimeout = TimeSpan.FromSeconds(35);

        public SandboxManager()
        {
            try
            {
                Uri uri = Environment.OSVersion.Platform == PlatformID.Win32NT
                    ? new Uri("npipe://./pipe/docker_engine")
                    : new Uri("unix:///var/run/docker.sock");
                Console.WriteLine("Docker client initialized successfully");

                _dockerClient = new DockerClientConfiguration(uri).CreateClient();
            }
            catch (Exception ex)
            {
                throw new Exception($"Failed to initialize Docker client: {ex.Message}", ex);
            }
        }
        public async Task<string> ExecuteCodeAsync(string code, string language, string taskId)
        {
            Console.WriteLine("Creating container...");
            string ext = DockerConfig.GetExtension(language);
            string fileName = $"code.{ext}";
            string outputPath = "/tmp/output.txt";

            CreateContainerResponse? container = null;
            
            try
            {
                Console.WriteLine("Creating container with timeout...");


                try
                {
                    container = await _dockerClient.Containers.CreateContainerAsync(new CreateContainerParameters
                {
                    Image = DockerConfig.GetDockerImage(language),
                    WorkingDir = "/tmp",
                    Tty = false,
                    AttachStdin = false,
                    AttachStdout = false,
                    AttachStderr = false,
                    OpenStdin = false,

                    HostConfig = new HostConfig
                    {
                        Memory = 512 * 1024 * 1024,
                        NanoCPUs = 500_000_000,
                        CapDrop = new List<string> { "ALL" },
                        SecurityOpt = new List<string> { "no-new-privileges:true" },
                        NetworkMode = "bridge", // ✅ Используем bridge вместо custom network
                        AutoRemove = false, // ✅ Автоматическое удаление контейнера
                    },
                    Cmd = new List<string> { "sleep", "300" }
                });
                }
                catch(Exception ex)
                {
                    return $"ExitCode=-1\n[Error Creating Container: {ex.Message}]";
                }
                
                
                Console.WriteLine($"Container created with ID: {container.ID}");
                Console.WriteLine("Starting container...");
                

                
                await _dockerClient.Containers.StartContainerAsync(container.ID, null);
                Console.WriteLine("Container started successfully");
                
                // Небольшая задержка для гарантии готовности контейнера
                await Task.Delay(500);

                await CopyFileToContainerAsync(container.ID, fileName, code);
            }
            catch (OperationCanceledException)
            {
                if (container != null)
                {
                    try
                    {
                        await _dockerClient.Containers.RemoveContainerAsync(
                            container.ID,
                            new ContainerRemoveParameters { Force = true }
                        );
                    }
                    catch { }
                }
                return "ExitCode=-1\n[Error: Container creation timed out after 30 seconds]";
            }
            try
            {
                // ✅ Создаем exec команду
                var execConfig = new ContainerExecCreateParameters
                {
                    Cmd = DockerConfig.GetExecuteCommand(language, fileName),
                    AttachStderr = true,
                    AttachStdout = true,
                };

                var execResponse = await _dockerClient.Exec.ExecCreateContainerAsync(
                    container.ID,
                    execConfig
                );

                // ✅ Запускаем exec (detached mode)
                await _dockerClient.Exec.StartContainerExecAsync(execResponse.ID);

                // Ждем завершения
                ContainerExecInspectResponse inspect;
                var timeout = TimeSpan.FromSeconds(35);
                var start = DateTime.UtcNow;

                do
                {
                    if (DateTime.UtcNow - start > timeout)
                    {
                        await _dockerClient.Containers.RemoveContainerAsync(
                            container.ID,
                            new ContainerRemoveParameters { Force = true }
                        );
                        return "ExitCode=-1\n[Timeout: execution exceeded 35 seconds]";
                    }

                    await Task.Delay(500);
                    inspect = await _dockerClient.Exec.InspectContainerExecAsync(execResponse.ID);
                }
                while (inspect.Running);

                // Читаем результат
                string output = await ReadFileFromContainerAsync(container.ID, outputPath);

                await _dockerClient.Containers.RemoveContainerAsync(
                    container.ID,
                    new ContainerRemoveParameters { Force = true }
                );

                long exitCode = inspect.ExitCode;
                return $"ExitCode={exitCode}\n{output}";
            }
            catch (Exception ex)
            {
                if (container != null)
                {
                    try
                    {
                        await _dockerClient.Containers.RemoveContainerAsync(
                            container.ID,
                            new ContainerRemoveParameters { Force = true }
                        );
                    }
                    catch { }
                }
                return $"ExitCode=-1\n[Error: {ex.Message}]";
            }
        }

        // для логов пока не используется
        // private async Task<string> ReadOutputAsync(string taskId,string containerId)
        // {
        //     string outputPath = Path.Combine("/shared", $"task_{taskId}", "output.txt");
        //     var stream = await _dockerClient.Containers.GetContainerLogsAsync(id: containerId, new ContainerLogsParameters
        //     {
        //         Follow = false,
        //         ShowStdout = true,
        //         ShowStderr = true,
        //         Tail = "all"
        //     }, CancellationToken.None);

        //     using var reader = new StreamReader(stream);
        //     string output = await reader.ReadToEndAsync();
        //     return output;
        // }
        private async Task CopyFileToContainerAsync(string containerId, string fileName, string content)
        {
            byte[] tarData;
            
            using (var memStream = new MemoryStream())
            {
                var writerOptions = new TarWriterOptions(CompressionType.None, false)
                {
                    LeaveStreamOpen = true,
                };

                using (var tarWriter = new TarWriter(memStream, writerOptions))
                {
                    using var fileData = new MemoryStream(Encoding.UTF8.GetBytes(content));
                    tarWriter.Write(fileName, fileData, DateTime.UtcNow);
                }

                tarData = memStream.ToArray();
            }

            using var tarStream = new MemoryStream(tarData);

            await _dockerClient.Containers.ExtractArchiveToContainerAsync(
                containerId,
                new ContainerPathStatParameters { Path = "/tmp" },
                tarStream
            );
        }

        // 📤 Чтение файла из контейнера
        private async Task<string> ReadFileFromContainerAsync(string containerId, string filePath)
        {
            try
            {
                var response = await _dockerClient.Containers.GetArchiveFromContainerAsync(containerId, new GetArchiveFromContainerParameters { Path = filePath }, false);
                using var tarStream = response.Stream;
                using var memStream = new MemoryStream();
                await tarStream.CopyToAsync(memStream);
                memStream.Seek(0, SeekOrigin.Begin);

                using var tar = TarArchive.Open(memStream);
                foreach (var entry in tar.Entries)
                {
                    if (!entry.IsDirectory)
                    {
                        using var reader = new StreamReader(entry.OpenEntryStream());
                        return await reader.ReadToEndAsync();
                    }
                }
            }
            catch(Exception ex)
            {
                return $"[Ошибка: файл вывода не создан]{ex}";
            }

            return "";
        }
    }
}