using Microsoft.AspNetCore.Mvc;
using VPT_Learn.Models;

namespace VPT_Learn.Controllers
{
    [ApiController]
    [Route("api/courses")]
    public class CourseController : ControllerBase
    {
        private readonly Supabase.Client _supabase;
        public CourseController([FromServices] Supabase.Client supabase)
        {
            _supabase = supabase;
        }
        [HttpGet("allcourses")]
        [Tags("Courses Management")]

        public async Task<IActionResult> AllCourses()
        {
            var user = HttpContext.Items["SupabaseUser"] as Supabase.Gotrue.User;
            if (user == null)
                return Unauthorized("Bearer token missing");

            var data = await _supabase
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
