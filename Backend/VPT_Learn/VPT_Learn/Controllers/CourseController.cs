using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VPT_Learn.Models;

namespace VPT_Learn.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/courses")]
    public class CourseController : ControllerBase
    {
        private readonly ISupabaseUserClientFactory _clientFactory;

        public CourseController(ISupabaseUserClientFactory clientFactory)
        {
            _clientFactory = clientFactory;
        }


        [HttpGet("allcourses")]
        [Tags("Courses Management")]
        public async Task<IActionResult> AllCourses()
        {
            var client = await _clientFactory.CreateAsync(HttpContext);

            var data = await client.From<Models.Course>().Get();

            var courses = data.Models.Select(e => new CourseDTO
            {
                CourseId = e.CourseId,
                Title = e.Title,
                Description = e.Description,
                Language = e.Language,
                Level = e.Level,
                CreatedBy = e.CreatedBy

            }).ToList();

            return Ok(new
            {
                courses = courses
            });
        }

        [HttpGet("{id}")]
        [Tags("Courses Management")]
        public async Task<IActionResult> GetCourse(int id)
        {
            var client = await _clientFactory.CreateAsync(HttpContext);

            var course = await client.From<Models.Course>()
                .Filter(c => c.CourseId, Supabase.Postgrest.Constants.Operator.Equals, id)
                .Single();

            if (course == null)
            {
                return NotFound(new { message = "Курс не найден" });
            }

            var courseDto = new CourseDTO
            {
                CourseId = course.CourseId,
                Title = course.Title,
                Description = course.Description,
                Language = course.Language,
                Level = course.Level,
                CreatedBy = course.CreatedBy
            };

            return Ok(courseDto);
        }

        [HttpPost]
        [Tags("Courses Management")]
        public async Task<IActionResult> CreateCourse([FromBody] CourseCreateDTO createDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var client = await _clientFactory.CreateAsync(HttpContext);

            var newCourse = new Models.Course
            {
                Title = createDto.Title,
                Description = createDto.Description,
                Language = createDto.Language,
                Level = createDto.Level,
                CreatedBy = createDto.CreatedBy
            };

            var result = await client.From<Models.Course>().Insert(newCourse);

            if (result.Models == null || result.Models.Count == 0)
            {
                return StatusCode(500, new { message = "Не удалось создать курс" });
            }

            var createdCourse = result.Models.First();
            var courseDto = new CourseDTO
            {
                CourseId = createdCourse.CourseId,
                Title = createdCourse.Title,
                Description = createdCourse.Description,
                Language = createdCourse.Language,
                Level = createdCourse.Level,
                CreatedBy = createdCourse.CreatedBy
            };

            return CreatedAtAction(nameof(GetCourse), new { id = courseDto.CourseId }, courseDto);
        }

        [HttpPut("{id}")]
        [Tags("Courses Management")]
        public async Task<IActionResult> UpdateCourse(int id, [FromBody] CourseUpdateDTO updateDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var client = await _clientFactory.CreateAsync(HttpContext);

            var existingCourse = await client.From<Models.Course>()
                .Filter(c => c.CourseId, Supabase.Postgrest.Constants.Operator.Equals, id)
                .Single();

            if (existingCourse == null)
            {
                return NotFound(new { message = "Курс не найден" });
            }

            existingCourse.Title = updateDto.Title ?? existingCourse.Title;
            existingCourse.Description = updateDto.Description ?? existingCourse.Description;
            existingCourse.Language = updateDto.Language ?? existingCourse.Language;
            existingCourse.Level = updateDto.Level ?? existingCourse.Level;

            var result = await client.From<Models.Course>().Update(existingCourse);

            if (result.Models == null || result.Models.Count == 0)
            {
                return StatusCode(500, new { message = "Не удалось обновить курс" });
            }

            var updatedCourse = result.Models.First();
            var courseDto = new CourseDTO
            {
                CourseId = updatedCourse.CourseId,
                Title = updatedCourse.Title,
                Description = updatedCourse.Description,
                Language = updatedCourse.Language,
                Level = updatedCourse.Level,
                CreatedBy = updatedCourse.CreatedBy
            };

            return Ok(courseDto);
        }

        [HttpDelete("{id}")]
        [Tags("Courses Management")]
        public async Task<IActionResult> DeleteCourse(int id)
        {
            var client = await _clientFactory.CreateAsync(HttpContext);

            var existingCourse = await client.From<Models.Course>()
                .Filter(c => c.CourseId, Supabase.Postgrest.Constants.Operator.Equals, id)
                .Single();

            if (existingCourse == null)
            {
                return NotFound(new { message = "Курс не найден" });
            }

            await client.From<Models.Course>()
                .Where(c => c.CourseId == id)
                .Delete();

            return NoContent();
        }
    }

    public class CourseCreateDTO
    {
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string Language { get; set; } = string.Empty;
        public string Level { get; set; } = string.Empty;
        public int CreatedBy { get; set; }
    }

    public class CourseUpdateDTO
    {
        public string? Title { get; set; }
        public string? Description { get; set; }
        public string? Language { get; set; }
        public string? Level { get; set; }
    }
}