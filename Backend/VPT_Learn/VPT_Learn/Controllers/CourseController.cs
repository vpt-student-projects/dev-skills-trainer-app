using Microsoft.AspNetCore.Mvc;
using VPT_Learn.Models;

namespace VPT_Learn.Controllers
{
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


            var data = await client
                .From<Models.Course>().Get();

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
    }
}
