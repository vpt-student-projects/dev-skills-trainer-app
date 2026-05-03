using Microsoft.AspNetCore.Mvc;
using VPT_Learn.Services;

namespace VPT_Learn.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ExecuteController : ControllerBase
    {
        private readonly CodeExecutionBackgroundService _worker;

        public ExecuteController(CodeExecutionBackgroundService worker)
        {
            _worker = worker;
        }

        public record ExecuteRequest(string Code, string Language);

        [HttpPost]
        public ActionResult Execute([FromBody] ExecuteRequest request)
        {
            var taskId = _worker.EnqueueTask(request.Code, request.Language);
            return Ok(new { taskId });
        }

        [HttpGet("{taskId}")]
        public ActionResult GetTaskResult(string taskId)
        {
            var result = _worker.GetTaskResult(taskId);
            if (result == null)
            {
                return NotFound(new { message = $"Task with ID {taskId} not found" });
            }
            return Ok(result);
        }
    }
}