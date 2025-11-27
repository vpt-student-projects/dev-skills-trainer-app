using Microsoft.AspNetCore.Mvc;
using Supabase;
using Supabase.Gotrue;
using Supabase.Gotrue.Interfaces;
using VPT_Learn.Models;

namespace VPT_Learn.Controllers
{
    [ApiController]
    [Route("api/user")]

    public class UserController : ControllerBase
    {
        private readonly Supabase.Client _supabase;
        public UserController([FromServices] Supabase.Client supabase)
        {
            _supabase = supabase;
        }

        [HttpGet("current")]
        public async Task<IActionResult> Current()
        {
            var user = HttpContext.Items["SupabaseUser"] as Supabase.Gotrue.User;
            
            if (user == null)
                return Unauthorized("Bearer token missing");

            var uid = user.Id;

            var userdata = await _supabase
                .From<Models.User>().Get(); //.Filter("user_uuid", Supabase.Postgrest.Constants.Operator.Equals, user.Id).Single();

            return Ok(userdata.Content);
        }

    }
}
