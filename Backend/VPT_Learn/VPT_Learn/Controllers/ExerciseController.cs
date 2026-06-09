using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VPT_Learn.Models;

namespace VPT_Learn.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/exercise")]
    public class ExerciseController : ControllerBase
    {
        private readonly ISupabaseUserClientFactory _clientFactory;

        public ExerciseController(ISupabaseUserClientFactory clientFactory)
        {
            _clientFactory = clientFactory;
        }

        /// <summary>
        /// Получить упражнение по lessonId
        /// </summary>
        [HttpGet("{lessonId}")]
        [Tags("Exercise Management")]
        public async Task<IActionResult> GetExercise(int lessonId)
        {
            var client = await _clientFactory.CreateAsync(HttpContext);

            var exercise = await client
                .From<CodeExercise>()
                .Filter(
                    x => x.LessonId,
                    Supabase.Postgrest.Constants.Operator.Equals,
                    lessonId)
                .Single();

            if (exercise == null)
            {
                return NotFound(new
                {
                    message = "Упражнение не найдено"
                });
            }

            var dto = new CodeExerciseDTO
            {
                Id = exercise.Id,
                CreatedAt = exercise.CreatedAt,
                Code = exercise.Code,
                TaskDescription = exercise.TaskDescription
            };

            return Ok(dto);
        }
    }
}