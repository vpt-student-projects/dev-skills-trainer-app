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

        private readonly ISupabaseUserClientFactory _clientFactory;

        public UserController(ISupabaseUserClientFactory clientFactory)
        {
            _clientFactory = clientFactory;
        }
        [HttpGet("current")]
        public async Task<IActionResult> Current()
        {
            var client = await _clientFactory.CreateAsync(HttpContext);

            if (client == null)
                return Unauthorized("Bearer token missing");

            var userdata = await client.From<Models.User>().Get(); //.Filter("user_uuid", Supabase.Postgrest.Constants.Operator.Equals, user.Id).Single();

            return Ok(userdata.Content);
        }
        [HttpPost("update_password")]
        public async Task<IActionResult> UpdatePassword([FromBody] UpdatePasswordRequest request)
        {
            var client = await _clientFactory.CreateAsync(HttpContext);



            if (client == null)
                return Unauthorized("Bearer token missing");

            if (string.IsNullOrEmpty(request.NewPassword) || request.NewPassword.Length < 6)
                return BadRequest(new { error = "Password must be at least 6 characters long" });

            try
            {
                var attrs = new UserAttributes { Password = request.NewPassword };
                var response = await client.Auth.Update(attrs);

                if (response == null)
                    return BadRequest(new { error = "error" });

                return Ok(new
                {
                    message = "Password updated successfully",
                    timestamp = DateTime.UtcNow
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "Failed to update password", details = ex.Message });
            }
        }

        // Модель для запроса
        public class UpdatePasswordRequest
        {
            public string NewPassword { get; set; } = string.Empty;
        }
        [HttpPost("update_email")]
        public async Task<IActionResult> UpdateEmail([FromBody] string email)
        {
            var client = await _clientFactory.CreateAsync(HttpContext);

            if (client == null)
                return Unauthorized("Bearer token missing");
            var attrs = new UserAttributes { Email = email };
            var response = await client.Auth.Update(attrs);
            return Ok();
        }

    }
}
