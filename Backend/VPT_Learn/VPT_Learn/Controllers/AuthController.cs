    using Microsoft.AspNetCore.Mvc;
    using VPT_Learn.Models;

    using Supabase;
    using Supabase.Gotrue;

namespace VPT_Learn.Controllers
{
    [ApiController]
    [Route("api/auth")]
    public partial class AuthController : ControllerBase
    {


        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDTO dto, [FromServices] Supabase.Client supabase)
        {
            try
            {
                var result = await supabase.Auth.SignUp(dto.Email, dto.Password);

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
        public async Task<IActionResult> Login([FromBody] LoginDTO dto, [FromServices] Supabase.Client supabase)
        {
            try
            {
                var result = await supabase.Auth.SignInWithPassword(dto.Email, dto.Password);

                if (result.User == null)
                    return Unauthorized("Неверный email или пароль");
               
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
        [HttpPost("signout")]
        public async Task<IActionResult> Signout([FromBody] LoginDTO dto, [FromServices] Supabase.Client supabase)
        {
            try
            {
                await supabase.Auth.SignOut();
                return Ok();
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }
    }
}
