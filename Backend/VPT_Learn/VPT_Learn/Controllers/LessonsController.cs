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

        private readonly ISupabaseUserClientFactory _clientFactory;

        public LessonsController(ISupabaseUserClientFactory clientFactory)
        {
            _clientFactory = clientFactory;
        }
        private Supabase.Client CreateUserClient(string accessToken)
        {
            var options = new SupabaseOptions
            {
                AutoRefreshToken = false,
            };

            return new Supabase.Client(
                Environment.GetEnvironmentVariable("SUPABASE_URL"),
                accessToken,
                options
            );
        }

        [Tags("Tasks Management")]
        [HttpGet("alltasks")]
        public async Task<IActionResult> AllTasks([FromQuery] int lessonId)
        {

            var client = await _clientFactory.CreateAsync(HttpContext);


            var data = await client
                .From<Exercise>()
                .Filter("lesson_id", Supabase.Postgrest.Constants.Operator.Equals, lessonId)
                .Get();

            var exercises = data.Models.Select(e => new ExerciseDTO
            {
                ExerciseId = e.ExerciseId,
                LessonId = e.LessonId,
                TaskDescription = e.TaskDescription,
                RightAnswer = e.RightAnswer
            });

            return Ok(new
            {
                count = exercises.Count(),
                exercises
            });
        }

        [HttpGet("alllessons")]
        [Tags("Tasks Management")]

        public async Task<IActionResult> AllLesssons([FromQuery] int courseid)
        {
            var client = await _clientFactory.CreateAsync(HttpContext);
            var data = await client
                .From<Models.Lesson>()
                .Filter("course_id", Supabase.Postgrest.Constants.Operator.Equals, courseid)
                .Get();

            var lessons = data.Models.Select(e => new LessonDTO
            {
                LessonId = e.LessonId,
                CourseId = e.CourseId,
                Title = e.Title,
                Content = e.Content,
                OrderIndex = e.OrderIndex
            }).ToList();

            return Ok(new
            {
                count = lessons.Count,
                lessons = lessons
            });
        }
    }


}
