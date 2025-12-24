using Microsoft.AspNetCore.Mvc;
using VPT_Learn.Models;

using Supabase;
using Supabase.Gotrue;
using Newtonsoft.Json.Linq;

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

                var userClient = new Supabase.Client(
                    Environment.GetEnvironmentVariable("SUPABASE_URL")!,
                    Environment.GetEnvironmentVariable("SUPABASE_KEY"),
                     new SupabaseOptions
                     {
                         AutoConnectRealtime = false,
                         Headers = new Dictionary<string, string>
                          {
                            { "Authorization", $"Bearer { result.AccessToken}" }
                          }
                     }
                );
                var userData = await userClient
                .From<Models.User>()
                .Filter("user_uuid", Supabase.Postgrest.Constants.Operator.Equals, result.User.Id)
                .Single();

                return Ok(new
                {
                    userId = result.User.Id,
                    email = result.User.Email,
                    accessToken = result.AccessToken,
                    refreshToken = result.RefreshToken,
                    role = userData.Role
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

                // 2. Создаем userClient для выполнения запросов к базе

                var userClient = new Supabase.Client(
                    Environment.GetEnvironmentVariable("SUPABASE_URL")!,
                    Environment.GetEnvironmentVariable("SUPABASE_KEY"),
                     new SupabaseOptions
                     {
                         AutoConnectRealtime = false,
                         Headers = new Dictionary<string, string>
                          {
                            { "Authorization", $"Bearer { result.AccessToken}" }
                          }
                     }
                );


                // 3. Получаем пользователя из таблицы public.users по user_uuid
                var userData = await userClient
                    .From<Models.User>()
                    .Filter("user_uuid", Supabase.Postgrest.Constants.Operator.Equals, result.User.Id)
                    .Single();

                if (userData == null)
                    return NotFound("User not found");

                // 4. Проверяем роль

                // 5. Возвращаем данные пользователю
                return Ok(new
                {
                    userId = result.User.Id,
                    email = result.User.Email,
                    accessToken = result.AccessToken,
                    refreshToken = result.RefreshToken,
                    role = userData.Role
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
