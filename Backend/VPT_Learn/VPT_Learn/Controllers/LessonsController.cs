using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Supabase;
using Supabase.Gotrue;
using Supabase.Gotrue.Interfaces;
using VPT_Learn.Models;

namespace VPT_Learn.Controllers
{
    [ApiController]
    [Authorize]
    [Route("api/lessons")]

    public class LessonsController : ControllerBase
    {

        private readonly ISupabaseUserClientFactory _clientFactory;

        public LessonsController(ISupabaseUserClientFactory clientFactory)
        {
            _clientFactory = clientFactory;
        }

        [Tags("Tasks Management")]
        [HttpGet("alltasks")]
        public async Task<IActionResult> AllTasks([FromQuery] int lessonId)
        {
            var client = await _clientFactory.CreateAsync(HttpContext);

            // Получаем упражнения по уроку
            var exerciseResponse = await client
                .From<Exercise>()
                .Filter("lesson_id", Supabase.Postgrest.Constants.Operator.Equals, lessonId)
                .Get();

            var exercises = new List<ExerciseDTO>();

            foreach (var e in exerciseResponse.Models)
            {
                // Получаем все ответы для данного упражнения
                var answersResponse = await client
                    .From<AnswerClass>()
                    .Filter("exercise_id", Supabase.Postgrest.Constants.Operator.Equals, e.ExerciseId).Select("*").Get();

                var answers = answersResponse.Models.Select(a => new AnswerDTO
                {
                    Id = a.Id,
                    ExerciseId = a.ExerciseId,
                    Answer = a.Answer,
                }).ToList();
                exercises.Add(new ExerciseDTO
                {
                    ExerciseId = e.ExerciseId,
                    LessonId = e.LessonId,
                    TaskDescription = e.TaskDescription,
                    RightAnswer = e.RightAnswer,
                    OrderIndex = e.OrderIndex,
                    Answers = answers
                });

            }

            return Ok(new
            {
                count = exercises.Count,
                exercises = exercises
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
