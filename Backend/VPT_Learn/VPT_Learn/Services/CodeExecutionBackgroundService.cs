using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System.Collections.Concurrent;
using System.Threading;
using System.Threading.Tasks;
using worker;

namespace VPT_Learn.Services
{
    /// <summary>
    /// Background service that processes code execution tasks from an in‑memory queue.
    /// </summary>
    public class CodeExecutionBackgroundService : BackgroundService
    {
        private readonly BlockingCollection<CodeExecutionTask> _queue =
            new BlockingCollection<CodeExecutionTask>(new ConcurrentQueue<CodeExecutionTask>());

        private readonly SandboxManager _sandboxManager;
        private readonly ILogger<CodeExecutionBackgroundService> _logger;

        public CodeExecutionBackgroundService(
            SandboxManager sandboxManager,
            ILogger<CodeExecutionBackgroundService> logger)
        {
            _sandboxManager = sandboxManager;
            _logger = logger;
        }

        /// <summary>
        /// Enqueue a new code execution task.
        /// </summary>
        public string EnqueueTask(string code, string language, string? taskId = null)
        {
            taskId ??= Guid.NewGuid().ToString();
            _queue.Add(new CodeExecutionTask
            {
                Code = code,
                Language = language,
                TaskId = taskId
            });
            return taskId;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("CodeExecutionBackgroundService started.");

            // Ограничиваем количество одновременно исполняемых задач
            var maxConcurrent = new SemaphoreSlim(3); // 3 параллельных задачи

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    // Пытаемся взять задачу с таймаутом 5 сек, чтобы не зависнуть
                    var task = await Task.Run(() => {
                    if (_queue.TryTake(out var item, 5000)) {
                        return item;          // элемент найден
                    } else {
                        return null;     // очередь пуста – возвращаем значение по умолчанию
                    }
                });

                    if (task == null)
                    {
                        // Очередь пуста – небольшая пауза, чтобы не крутить CPU
                        await Task.Delay(500, stoppingToken);
                        continue;
                    }

                    // Ограничиваем параллелизм
                    await maxConcurrent.WaitAsync(stoppingToken);
                    try
                    {
                        _logger.LogInformation($"Processing task {task.TaskId}");
                        var result = await ExecuteTaskWithTimeout(task, stoppingToken);
                        ReturnOutput(task.TaskId, "completed", result);
                    }
                    finally
                    {
                        maxConcurrent.Release();
                    }
                }
                catch (OperationCanceledException)
                {
                    break; // корректное завершение
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error processing task");
                }
            }

            _logger.LogInformation("CodeExecutionBackgroundService stopped.");
        }

        private async Task<string> ExecuteTaskWithTimeout(CodeExecutionTask task, CancellationToken ct)
        {
            using var cts = CancellationTokenSource.CreateLinkedTokenSource(ct);
            cts.CancelAfter(TimeSpan.FromSeconds(45)); // 45 сек максимум на всю операцию

            try
            {
                return await _sandboxManager.ExecuteCodeAsync(task.Code, task.Language, task.TaskId);
            }
            catch (OperationCanceledException)
            {
                return "ExitCode=-1\n[Timeout: operation exceeded 45 seconds]";
            }
            catch (Exception ex)
            {
                return $"ExitCode=-1\n[Error: {ex.Message}]";
            }
        }

        private string ReturnOutput(string taskId, string status, string output)
        {
            //var output = new CodeExecutionTask { TaskId = taskId, Status = status, Output = output };
            return output;
        }
    }

    internal class CodeExecutionTask
    {
         public string Code { get; set; } = string.Empty;
        public string Language { get; set; } = string.Empty;
        public string TaskId { get; set; } = string.Empty;
    }
}
