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

        private readonly ConcurrentDictionary<string, TaskResult> _taskResults = 
            new ConcurrentDictionary<string, TaskResult>();

        private readonly SandboxManager _sandboxManager;
        private readonly ILogger<CodeExecutionBackgroundService> _logger;
        private readonly Supabase.Client _supabaseClient;

        public CodeExecutionBackgroundService(
            SandboxManager sandboxManager,
            ILogger<CodeExecutionBackgroundService> logger,
            Supabase.Client supabaseClient)
        {
            _sandboxManager = sandboxManager;
            _logger = logger;
            _supabaseClient = supabaseClient;
                _logger.LogInformation($"Supabase client initialized with role: {supabaseClient.Auth.CurrentSession?.User?.Role ?? "No session/Service Role"}");
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

        public string EnqueueTaskWithSubmission(string code, string language, int exerciseId, int userId, string? taskId = null)
        {
            taskId ??= Guid.NewGuid().ToString();
            _queue.Add(new CodeExecutionTask
            {
                Code = code,
                Language = language,
                TaskId = taskId,
                ExerciseId = exerciseId,
                UserId = userId,
                SaveToDatabase = true
            });
            return taskId;
        }

        /// <summary>
        /// Get the result of a task by its ID.
        /// </summary>
        public TaskResult? GetTaskResult(string taskId)
        {
            _taskResults.TryGetValue(taskId, out var result);
            return result;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("CodeExecutionBackgroundService started.");

            var maxConcurrent = new SemaphoreSlim(3);

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    var task = await Task.Run(() => {
                        if (_queue.TryTake(out var item, 5000))
                        {
                            return item;
                        }
                        else
                        {
                            return null;
                        }
                    });

                    if (task == null)
                    {
                        await Task.Delay(500, stoppingToken);
                        continue;
                    }

                    await maxConcurrent.WaitAsync(stoppingToken);
                    try
                    {
                        _logger.LogInformation($"Processing task {task.TaskId}");
                        var result = await ExecuteTaskWithTimeout(task, stoppingToken);
                        
                        bool? isCorrect = null;
                        if (task.SaveToDatabase && task.ExerciseId.HasValue && task.UserId.HasValue)
                        {
                            var parsedResult = ReturnOutput(task.TaskId, "completed", result);
                            string resultStatus = DetermineResultStatus(parsedResult.ExitCode, parsedResult.Output);
                            
                            if (parsedResult.ExitCode == "0")
                            {
                                isCorrect = await IsAnswerCorrect(task.ExerciseId.Value, parsedResult.Output);
                            }
                            
                            await SaveOrUpdateSubmission(
                                task.ExerciseId.Value,
                                task.UserId.Value,
                                task.Code,
                                parsedResult.ExitCode,
                                parsedResult.Output,
                                resultStatus,
                                isCorrect
                            );
                            
                            // Обновляем TaskResult с информацией о правильности
                            var taskResult = _taskResults.GetValueOrDefault(task.TaskId);
                            if (taskResult != null)
                            {
                                taskResult.IsCorrect = isCorrect;
                            }
                        }
                        else
                        {
                            ReturnOutput(task.TaskId, "completed", result);
                        }
                    }
                    finally
                    {
                        maxConcurrent.Release();
                    }
                }
                catch (OperationCanceledException)
                {
                    break;
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
            cts.CancelAfter(TimeSpan.FromSeconds(45));

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

        private ParsedResult ReturnOutput(string taskId, string status, string output)
        {
            var lines = output.Split('\n');
            string exitCode = lines[0].Split('=')[1];
            string data = string.Join("\n", lines.Skip(1));
            data = data.TrimEnd('\n', '\r');
            data = data.TrimEnd();

            var result = new TaskResult
            {
                TaskId = taskId,
                Status = status,
                ExitCode = exitCode,
                Output = data,
                CompletedAt = DateTime.UtcNow,
                IsCorrect = null // Пока неизвестно, будет установлено позже
            };
            _taskResults[taskId] = result;
            
            return new ParsedResult
            {
                ExitCode = exitCode,
                Output = data
            };
        }

        public async Task<string?> GetRightAnswerForExercise(int exerciseId)
        {
            try
            {
                var response = await _supabaseClient
                    .From<Models.CodeExercise>()
                    .Where(e => e.Id == exerciseId)
                    .Get();

                var exercise = response.Models?.FirstOrDefault();
                return exercise?.RightAnswer;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Failed to get right answer for exercise {exerciseId}");
                return null;
            }
        }

        private async Task SaveOrUpdateSubmission(int exerciseId, int userId, string code, string exitCode, string consoleOutput, string resultStatus, bool? isCorrect)
        {
            try
            {
                string outputToSave = consoleOutput;
                if (!string.IsNullOrEmpty(outputToSave) && outputToSave.Length > 10000)
                {
                    outputToSave = outputToSave.Substring(0, 10000) + "... (truncated)";
                    _logger.LogWarning($"Output truncated for exercise {exerciseId}, user {userId}");
                }
                
                var existingSubmission = await _supabaseClient
                    .From<Models.Submission>()
                    .Where(s => s.ExerciseId == exerciseId && s.UserId == userId)
                    .Order(s => s.SubmittedAt, Supabase.Postgrest.Constants.Ordering.Descending)
                    .Get();

                if (existingSubmission.Models != null && existingSubmission.Models.Count > 0)
                {
                    var submissionToUpdate = existingSubmission.Models.First();
                    submissionToUpdate.SubmittedCode = code;
                    submissionToUpdate.Result = resultStatus;
                    submissionToUpdate.IsCorrect = isCorrect;
                    submissionToUpdate.Output = outputToSave;
                    submissionToUpdate.SubmittedAt = DateTime.UtcNow;

                    await _supabaseClient
                        .From<Models.Submission>()
                        .Where(s => s.SubmissionId == submissionToUpdate.SubmissionId)
                        .Update(submissionToUpdate);
                        
                    _logger.LogInformation($"Submission updated for exercise {exerciseId}, user {userId}. Result: {resultStatus}, IsCorrect: {isCorrect}");
                }
                else
                {
                    var newSubmission = new Models.Submission
                    {
                        ExerciseId = exerciseId,
                        UserId = userId,
                        SubmittedCode = code,
                        Result = resultStatus,
                        IsCorrect = isCorrect,
                        Output = outputToSave,
                        SubmittedAt = DateTime.UtcNow
                    };

                    await _supabaseClient
                        .From<Models.Submission>()
                        .Insert(newSubmission);
                        
                    _logger.LogInformation($"Submission created for exercise {exerciseId}, user {userId}. Result: {resultStatus}, IsCorrect: {isCorrect}");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Failed to save/update submission for exercise {exerciseId}, user {userId}");
            }
        }

        private async Task<bool?> IsAnswerCorrect(int exerciseId, string consoleOutput)
        {
            try
            {
                var rightAnswer = await GetRightAnswerForExercise(exerciseId);
                
                if (string.IsNullOrEmpty(rightAnswer))
                {
                    _logger.LogWarning($"No right answer defined for exercise {exerciseId}");
                    return null;
                }
                
                string normalizedOutput = consoleOutput?.Trim() ?? string.Empty;
                string normalizedRightAnswer = rightAnswer.Trim();
                
                bool isCorrect = string.Equals(normalizedOutput, normalizedRightAnswer, StringComparison.OrdinalIgnoreCase);
                
                if (!isCorrect && normalizedOutput.Contains(normalizedRightAnswer))
                {
                    isCorrect = true;
                }
                
                _logger.LogDebug($"Answer comparison for exercise {exerciseId}: Expected: '{normalizedRightAnswer}', Actual: '{normalizedOutput}', Result: {(isCorrect ? "MATCH" : "NO MATCH")}");
                
                return isCorrect;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error checking answer correctness for exercise {exerciseId}");
                return null;
            }
        }

        private string DetermineResultStatus(string exitCode, string output)
        {
            if (exitCode != "0")
                return "ошибка";

            var outputLower = output.ToLower();
            
            if (outputLower.Contains("all tests passed") || 
                outputLower.Contains("success") || 
                outputLower.Contains("congratulations") ||
                outputLower.Contains("все тесты пройдены"))
            {
                return "успех";
            }
            else if (outputLower.Contains("partial") || 
                     outputLower.Contains("some tests passed") ||
                     outputLower.Contains("частично"))
            {
                return "частично";
            }
            
            return "успех";
        }
    }

    internal class CodeExecutionTask
    {
        public string Code { get; set; } = string.Empty;
        public string Language { get; set; } = string.Empty;
        public string TaskId { get; set; } = string.Empty;
        public int? ExerciseId { get; set; }
        public int? UserId { get; set; }
        public bool SaveToDatabase { get; set; } = false;
    }

    public class TaskResult
    {
        public string TaskId { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public string ExitCode { get; set; } = string.Empty;
        public string Output { get; set; } = string.Empty;
        public DateTime CompletedAt { get; set; }
        public bool? IsCorrect { get; set; } // Добавлено поле IsCorrect
    }

    internal class ParsedResult
    {
        public string ExitCode { get; set; } = string.Empty;
        public string Output { get; set; } = string.Empty;
    }
}