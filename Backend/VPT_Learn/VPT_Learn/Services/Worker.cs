using System; 
using System.Net.Http; 
using System.Text; using 
System.Threading.Tasks; 
using System.Text.Json; 
using System.Collections.Generic; 
using System.Net.Http.Headers; 
using Docker.DotNet; 
using Docker.DotNet.Models; 
using System.IO; using worker;
 namespace VPT_Learn.Services 
 { 
    public class Worker 
    { 
        private static readonly DockerClient _dockerClient = new DockerClientConfiguration(new Uri("unix:///var/run/docker.sock")).CreateClient();
         private static readonly string _supabaseUrl = Environment.GetEnvironmentVariable("SUPABASE_URL");
          private static readonly string _supabaseKey = Environment.GetEnvironmentVariable("SUPABASE_KEY"); 
          private static SandboxManager _sandboxManager = new SandboxManager(); 
          public static async Task<string> ProcessTaskAsync(string code, string language, string taskId) 
          { 
            string output = await _sandboxManager.ExecuteCodeAsync(code, language, taskId); 
            return output; 
        } 
        private static async Task UpdateTaskStatus(string taskId, string status, string output) 
        { 
            using var httpClient = new HttpClient(); 
            var request = new HttpRequestMessage(HttpMethod.Patch, $"{_supabaseUrl}/rest/v1/compilation_tasks?id=eq.{taskId}"); 
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _supabaseKey);
             var payload = new { status, output, exec_time = DateTime.UtcNow }; 
             request.Content = new StringContent(JsonSerializer.Serialize(payload), Encoding.UTF8, "application/json"); 
             await httpClient.SendAsync(request); 
        } 
    } 
}
