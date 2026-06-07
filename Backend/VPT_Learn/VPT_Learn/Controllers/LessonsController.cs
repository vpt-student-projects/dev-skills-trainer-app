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
            
            if (!exerciseResponse.Models.Any())
            {
                return Ok(new { count = 0, exercises = new List<ExerciseDTO>() });
            }
            
            // Получаем все ответы одним запросом
            var exerciseIds = exerciseResponse.Models.Select(e => e.ExerciseId).ToList();
            var answersResponse = await client
                .From<AnswerClass>()
                .Filter("exercise_id", Supabase.Postgrest.Constants.Operator.In, exerciseIds)
                .Get();
            
            // Группируем ответы
            var answersByExerciseId = answersResponse.Models
                .GroupBy(a => a.ExerciseId)
                .ToDictionary(g => g.Key, g => g.Select(a => new AnswerDTO
                {
                    Id = a.Id,
                    ExerciseId = a.ExerciseId,
                    Answer = a.Answer,
                }).ToList());
            
            // Формируем результат
            var exercises = exerciseResponse.Models.Select(e => new ExerciseDTO
            {
                ExerciseId = e.ExerciseId,
                LessonId = e.LessonId,
                TaskDescription = e.TaskDescription,
                RightAnswer = e.RightAnswer,
                OrderIndex = e.OrderIndex,
                Answers = answersByExerciseId.GetValueOrDefault(e.ExerciseId, new List<AnswerDTO>())
            }).ToList();
            
            return Ok(new
            {
                count = exercises.Count,
                exercises = exercises
            });
        }

        [HttpGet("alllessons")]
        [Tags("Tasks Management")]
        public async Task<IActionResult> AllLessons([FromQuery] int courseId)
        {
            var client = await _clientFactory.CreateAsync(HttpContext);
            var data = await client
                .From<Models.Lesson>()
                .Filter("course_id", Supabase.Postgrest.Constants.Operator.Equals, courseId)
                .Get();

            var lessons = data.Models.Select(e => new LessonDTO
            {
                LessonId = e.LessonId,
                CourseId = e.CourseId,
                Title = e.Title,
                Content = e.Content,
                OrderIndex = e.OrderIndex,
                Type = e.Type
            }).ToList();

            return Ok(new
            {
                count = lessons.Count,
                lessons = lessons
            });
        }

        [HttpPost]
        [Tags("Tasks Management")]
        public async Task<IActionResult> CreateLesson([FromBody] LessonDTO lessonDto)
        {
            var client = await _clientFactory.CreateAsync(HttpContext);

            var lesson = new Lesson
            {
                CourseId = lessonDto.CourseId,
                Title = lessonDto.Title,
                Content = lessonDto.Content,
                OrderIndex = lessonDto.OrderIndex,
                Type = lessonDto.Type
            };

            var response = await client.From<Lesson>().Insert(lesson);

            if (response.Models == null || !response.Models.Any())
            {
                return BadRequest(new { message = "Не удалось создать урок" });
            }

            var createdLesson = response.Models.First();
            var lessonResponse = new LessonDTO
            {
                LessonId = createdLesson.LessonId,
                CourseId = createdLesson.CourseId,
                Title = createdLesson.Title,
                Content = createdLesson.Content,
                OrderIndex = createdLesson.OrderIndex,
                Type = createdLesson.Type
            };

            return Ok(new
            {
                message = "Урок успешно создан",
                lesson = lessonResponse
            });
        }

        [HttpPut("{lessonId}")]
        [Tags("Tasks Management")]
        public async Task<IActionResult> UpdateLesson(int lessonId, [FromBody] LessonDTO lessonDto)
        {
            var client = await _clientFactory.CreateAsync(HttpContext);

            var lesson = new Lesson
            {
                LessonId = lessonId,
                CourseId = lessonDto.CourseId,
                Title = lessonDto.Title,
                Content = lessonDto.Content,
                OrderIndex = lessonDto.OrderIndex,
                Type = lessonDto.Type
            };

            var response = await client.From<Lesson>().Update(lesson);

            if (response.Models == null || !response.Models.Any())
            {
                return NotFound(new { message = "Урок не найден" });
            }

            var updatedLesson = response.Models.First();
            var lessonResponse = new LessonDTO
            {
                LessonId = updatedLesson.LessonId,
                CourseId = updatedLesson.CourseId,
                Title = updatedLesson.Title,
                Content = updatedLesson.Content,
                OrderIndex = updatedLesson.OrderIndex,
                Type = updatedLesson.Type
            };

            return Ok(new
            {
                message = "Урок успешно обновлен",
                lesson = lessonResponse
            });
        }

        [HttpDelete("{lessonId}")]
        [Tags("Tasks Management")]
        public async Task<IActionResult> DeleteLesson(int lessonId)
        {
            var client = await _clientFactory.CreateAsync(HttpContext);

            var existingLesson = await client.From<Models.Lesson>()
                .Filter(c => c.CourseId, Supabase.Postgrest.Constants.Operator.Equals, lessonId)
                .Single();

            if (existingLesson == null)
            {
                return NotFound(new { message = "Урок не найден" });
            }
            
            await client.From<Models.Lesson>().Where(c => c.LessonId == lessonId).Delete();


            return Ok(new
            {
                message = "Урок успешно удален"
            });
        }
    }
}