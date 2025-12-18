using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Supabase;
using Supabase.Gotrue;
using Supabase.Gotrue.Interfaces;
using VPT_Learn.Models;

namespace VPT_Learn.Controllers
{
    [Authorize]
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

            // 1. Получаем auth-пользователя из JWT
            var authUser = client.Auth.CurrentUser;

            if (authUser == null)
                return Unauthorized("Invalid token");

            // 2. Получаем пользователя из public.users по user_uuid
            var data = await client
                .From<Models.User>()
                .Filter("user_uuid", Supabase.Postgrest.Constants.Operator.Equals, authUser.Id)
                .Single();

            if (data == null)
                return NotFound("User not found");

            // 3. Маппинг в DTO
            var userDto = new UserDTO
            {
                UserId = data.UserId,
                Name = data.Name,
                Email = data.Email,
                Role = data.Role,
                CreatedAt = data.CreatedAt,
                UserUuid = data.UserUuid
                // PasswordHash ❌ НЕ возвращаем
            };

            return Ok(userDto);
        }


       
        


        private async Task<bool> IsAdmin(Supabase.Client client)
        {
            // Получаем auth пользователя
            var authUser = client.Auth.CurrentUser;
            if (authUser == null)
                return false;

            // Получаем запись из public.users
            var userData = await client
                .From<Models.User>()
                .Filter("user_uuid", Supabase.Postgrest.Constants.Operator.Equals, authUser.Id)
                .Single();

            if (userData == null)
                return false;

            return userData.Role == "админ";
        }

        //[HttpPost("update_password")]
        //public async Task<IActionResult> UpdatePassword([FromBody] UpdatePasswordRequest request, Supabase.Client supabase)
        //{
        //    var client = await _clientFactory.CreateAsync(HttpContext);



        //    if (client == null)
        //        return Unauthorized("Bearer token missing");

        //    if (string.IsNullOrEmpty(request.NewPassword) || request.NewPassword.Length < 6)
        //        return BadRequest(new { error = "Password must be at least 6 characters long" });

        //    try
        //    {
        //        var attrs = new UserAttributes { Password = request.NewPassword };
        //        var response = await client.Auth.Update(attrs);

        //        if (response == null)
        //            return BadRequest(new { error = "error" });

        //        return Ok(new
        //        {
        //            message = "Password updated successfully",
        //            timestamp = DateTime.UtcNow
        //        });
        //    }
        //    catch (Exception ex)
        //    {
        //        return StatusCode(500, new { error = "Failed to update password", details = ex.Message });
        //    }
        //}

        //// Модель для запроса
        //public class UpdatePasswordRequest
        //{
        //    public string NewPassword { get; set; } = string.Empty;
        //}
        //[HttpPost("update_email")]
        //public async Task<IActionResult> UpdateEmail([FromBody] string email, Supabase.Client supabase)
        //{
        //    var client = await _clientFactory.CreateAsync(HttpContext);

        //    if (client == null)
        //        return Unauthorized("Bearer token missing");
        //    var attrs = new UserAttributes { Email = email };
        //    var response = await client.Auth.Update(attrs);
        //    return Ok();
        //}

        [HttpPost("make-admin")]
        public async Task<IActionResult> MakeAdmin([FromBody] Guid userUuid,[FromServices] Supabase.Client supabase)
        {
            await supabase
                .From<Models.User>()
                .Filter("user_uuid", Supabase.Postgrest.Constants.Operator.Equals, userUuid)
                .Set(u => u.Role, "админ")
                .Update();

            return Ok();
        }

    }
}
