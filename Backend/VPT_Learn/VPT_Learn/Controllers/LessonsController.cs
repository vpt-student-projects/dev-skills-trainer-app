using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Supabase;
using Supabase.Gotrue;
using Supabase.Gotrue.Interfaces;
using VPT_Learn.Models;
using VPT_Learn.Services;

namespace VPT_Learn.Controllers
{
    [ApiController]
    [Authorize]
    [Route("api/lessons")]

    public class LessonsController : ControllerBase
    {
        private readonly ISupabaseUserClientFactory _clientFactory;
        private readonly TestCheckingService _testCheckingService;

        public LessonsController(ISupabaseUserClientFactory clientFactory)
        {
            _clientFactory = clientFactory;
            _testCheckingService = new TestCheckingService();

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

        private async Task<List<Exercise>> GetExercisesByLessonId(int lessonId)
        {
            var client = await _clientFactory.CreateAsync(HttpContext);
            
            // Получаем упражнения по уроку
            var exerciseResponse = await client
                .From<Exercise>()
                .Filter("lesson_id", Supabase.Postgrest.Constants.Operator.Equals, lessonId)
                .Order("order_index", Supabase.Postgrest.Constants.Ordering.Ascending)
                .Get();
            
            if (!exerciseResponse.Models.Any())
                return new List<Exercise>();
            
            var exercises = exerciseResponse.Models.ToList();
            
            // Получаем все ответы для этих упражнений
            var exerciseIds = exercises.Select(e => e.ExerciseId).ToList();
            var answersResponse = await client
                .From<AnswerClass>()
                .Filter("exercise_id", Supabase.Postgrest.Constants.Operator.In, exerciseIds)
                .Get();
            
            // Группируем ответы по exercise_id
            var answersByExerciseId = answersResponse.Models
                .GroupBy(a => a.ExerciseId)
                .ToDictionary(g => g.Key, g => g.ToList());
            
            // Привязываем ответы к упражнениям
            foreach (var exercise in exercises)
            {
                exercise.Answers = answersByExerciseId.GetValueOrDefault(exercise.ExerciseId, new List<AnswerClass>());
            }
            
            return exercises;
        }

        /// <summary>
        /// Получить все ответы для всех упражнений урока
        /// </summary>
        private async Task<List<AnswerClass>> GetAllAnswersForLesson(int lessonId)
        {
            var client = await _clientFactory.CreateAsync(HttpContext);
            
            // Сначала получаем все упражнения урока
            var exercises = await GetExercisesByLessonId(lessonId);
            var exerciseIds = exercises.Select(e => e.ExerciseId).ToList();
            
            if (!exerciseIds.Any())
                return new List<AnswerClass>();
            
            // Получаем все ответы для этих упражнений
            var answersResponse = await client
                .From<AnswerClass>()
                .Filter("exercise_id", Supabase.Postgrest.Constants.Operator.In, exerciseIds)
                .Get();
            
            return answersResponse.Models.ToList();
        }

        /// <summary>
        /// Детальная проверка теста с пояснениями
        /// </summary>
        [HttpPost("submit-test/{lessonId}")]
        public async Task<IActionResult> SubmitTest(int lessonId, [FromBody] List<UserTestAnswer> userAnswers)
        {
            try
            {
                // Получаем все упражнения для урока
                var exercises = await GetExercisesByLessonId(lessonId);
                
                if (exercises == null || !exercises.Any())
                    return BadRequest(new { message = "Для этого урока нет заданий" });
                
                // Проверяем ответы
                var result = _testCheckingService.CheckUserAnswers(exercises, userAnswers);
                
                // Сохраняем результат в БД (опционально)
                // await SaveTestResult(lessonId, userId, result);
                
                return Ok(new 
                { 
                    message = "Тест проверен",
                    result = new
                    {
                        result.CorrectCount,
                        result.IncorrectCount,
                        result.TotalQuestions,
                        result.ScorePercentage,
                        details = result.Results.Select(r => new 
                        { 
                            r.QuestionId, 
                            r.IsCorrect 
                        })
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = $"Ошибка при проверке теста: {ex.Message}" });
            }
        }

    }
}