public class DockerConfig
    {
    public DockerConfig()
    {
        
    }

    public static string GetDockerImage(string language) => language switch
        {
            "cpp" => "vpt_learn-c-sandbox",
            "csharp" => "vpt_learn-csharp-sandbox",
            "python" => "vpt_learn-python-sandbox:latest",
            "java" => "vpt_learn-java-sandbox:latest",
            _ => throw new ArgumentException("Unsupported language")
        };
        public static List<string> GetExecuteCommand(string language, string fileName) => language switch
        {
            "cpp" => new List<string>
            {
                "sh", "-c",
                $"g++ /tmp/{fileName} -o /tmp/a.out && timeout 30 /tmp/a.out > /tmp/output.txt 2>&1 || echo 'Execution failed' > /tmp/output.txt"
            },
            "csharp" => new List<string> { "sh", "-c",
                $"export HOME=/tmp && export DOTNET_CLI_HOME=/tmp && timeout 30 dotnet-script '/tmp/{fileName}' > '/tmp/output.txt' 2>&1 || echo 'Execution failed' > '/tmp/output.txt'" },

            "python" => new List<string>
            {
                "sh", "-c",
                $"timeout 30 python3 /tmp/{fileName} > /tmp/output.txt 2>&1 || echo 'Execution failed' > /tmp/output.txt"
            },

            "java" => new List<string>
            {
                "sh", "-c",
                $"javac /tmp/{fileName} -d /tmp && timeout 30 java -cp /tmp Main > /tmp/output.txt 2>&1 || echo 'Execution failed' > /tmp/output.txt"
            },

            _ => throw new ArgumentException("Unsupported language")
        };
        public static string GetExtension(string language) => language switch
        {
            "python" => "py",
            "cpp" => "cpp",
            "csharp" => "csx",
            "java" => "java",
            _ => throw new ArgumentException("Unsupported language")
        };
    }