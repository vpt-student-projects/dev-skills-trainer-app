
    using Microsoft.AspNetCore.Mvc;
    using Supabase;
    using Supabase.Gotrue;
    using VPT_Learn.Models;
namespace VPT_Learn.Controllers
{
    [ApiController]
    [Route("api/auth")]
    public class AuthController : ControllerBase
    {
        private readonly Supabase.Client _client;

        public AuthController(Supabase.Client client)
        {
            _client = client;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto dto)
        {
            try
            {
                var result = await _client.Auth.SignUp(dto.Email, dto.Password);

                if (result.User == null)
                    return BadRequest("Не удалось зарегистрировать пользователя");

                var accessToken = result.AccessToken;

                return Ok(new
                {
                    userId = result.User.Id,
                    email = result.User.Email,
                    accessToken
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }



        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto dto)
        {
            try
            {
                var result = await _client.Auth.SignInWithPassword(dto.Email, dto.Password);

                if (result.User == null)
                    return Unauthorized("Неверный email или пароль");
               
                await _client.Auth.SetSession(result.AccessToken, result.RefreshToken, true);

                return Ok(new
                {
                    userId = result.User.Id,
                    email = result.User.Email,
                    accessToken = result.AccessToken,
                    refreshToken = result.RefreshToken
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }


        public class RegisterDto
        {
            public string Email { get; set; }
            public string Password { get; set; }
        }
        public class LoginDto
        {
            public string Email { get; set; }
            public string Password { get; set; }
        }
    }
}
