using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Supabase;
using Supabase.Gotrue;
using Supabase.Gotrue.Interfaces;
using VPT_Learn.Models;

namespace VPT_Learn.Controllers
{
    [ApiController]
    [Route("api/lessons")]

    public class LessonsController : ControllerBase
    {
        private readonly Supabase.Client _supabase;
        public LessonsController([FromServices] Supabase.Client supabase)
        {
            _supabase = supabase;
        }

        [HttpGet("alltasks")]
        [Tags("Tasks Management")]

        public async Task<IActionResult> AllTasks([FromQuery] int lessonId)
        {
            var user = HttpContext.Items["SupabaseUser"] as Supabase.Gotrue.User;
            if (user == null)
                return Unauthorized("Bearer token missing");

            var data = await _supabase
                .From<Models.Exercise>()
                .Filter("lesson_id", Supabase.Postgrest.Constants.Operator.Equals, lessonId)
                .Get();

            var exercises = data.Models.Select(e => new ExerciseDTO
            {
                ExerciseId = e.ExerciseId,
                LessonId = e.LessonId,
                TaskDescription = e.TaskDescription,
                RightAnswer = e.RightAnswer,
                
            }).ToList();

            return Ok(new
            {
                count = exercises.Count,
                exercises = exercises
            });
        }

    }


}
