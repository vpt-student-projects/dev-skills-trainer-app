using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Supabase;
using Supabase.Gotrue;
using VPT_Learn.Models;

namespace VPT_Learn.Controllers
{
    [ApiController]
    [Authorize]
    [Route("api/admin")]
    public class AdminController : ControllerBase
    {
        private readonly ISupabaseUserClientFactory _clientFactory;

        public AdminController(ISupabaseUserClientFactory clientFactory)
        {
            _clientFactory = clientFactory;
        }

        /// <summary>
        /// Получение всех пользователей (email и UUID)
        /// </summary>
        [HttpGet("users")]
        public async Task<IActionResult> GetAllUsers()
        {
            // 1. Создаём user client из контекста
            var userClient = await _clientFactory.CreateAsync(HttpContext);
            if (userClient == null) return Unauthorized();

            // 2. Проверяем, что это админ
            if (!await IsAdmin(userClient))
                return StatusCode(403, "Admin privileges required");

            // 3. Используем service_role для получения всех пользователей
            var adminClient = SupabaseAdmin.Create();
            var users = await adminClient.From<Models.User>().Get();
            if (users == null)
                return StatusCode(500, "Failed to fetch users");

            // 5. Формируем ответ с email и UUID
            var userList = users.Models.Select(u => new UserDTO()
            {
                UserUuid = u.UserUuid,      
                Email = u.Email
            }).ToList();

            return Ok(new
            {
                users = userList
            });
        }
        [HttpPost("admin/update-user-auth")]
        public async Task<IActionResult> AdminUpdateUserAuth(
        [FromBody] AdminUpdateUserRequest request)
        {
            var userClient = await _clientFactory.CreateAsync(HttpContext);
            if (userClient == null) return Unauthorized();



            if (string.IsNullOrWhiteSpace(request.NewEmail) &&
                string.IsNullOrWhiteSpace(request.NewPassword))
            {
                return BadRequest("Nothing to update");
            }

            // 2. Используем service_role
            if (!await IsAdmin(userClient))
                return StatusCode(403, "Admin privileges required");
            var adminClient = userClient.AdminAuth(Environment.GetEnvironmentVariable("SUPABASE_SERVICE_ROLE_KEY")!);
            var attrs = new UserAttributes();

            if (!string.IsNullOrWhiteSpace(request.NewEmail))
                attrs.Email = request.NewEmail;

            if (!string.IsNullOrWhiteSpace(request.NewPassword))
            {
                if (request.NewPassword.Length < 6)
                    return BadRequest("Password too short");

                attrs.Password = request.NewPassword;
            }
            request.UserUuid.ToString();
            var result = adminClient.UpdateUserById(request.UserUuid.ToString(),
            new Supabase.Gotrue.AdminUserAttributes()
            {
                Email = request.NewEmail,
                Password = request.NewPassword
            });
            var publicUpdate = new Dictionary<string, object>();

            if (!string.IsNullOrWhiteSpace(request.NewEmail))
                publicUpdate["email"] = request.NewEmail;

            if (!string.IsNullOrWhiteSpace(request.NewPassword))
                publicUpdate["password_hash"] = request.NewPassword;
            var adminClientPublic = SupabaseAdmin.Create();
            var users = await adminClientPublic.From<Models.User>().Where(x => x.Email == publicUpdate["email"]).Set(x => x.Email, request.NewEmail).Update();
            if (users == null)
                return StatusCode(500, "Failed to fetch users");

            // 5. Формируем ответ с email и UUID
            var userList = users.Models.Select(u => new UserDTO()
            {
                UserUuid = u.UserUuid,
                Email = u.Email
            }).ToList();        


            if (result == null)
                return StatusCode(500, "Failed to update user");

            return Ok(new
            {
                message = "User credentials updated",
                userId = request.UserUuid
            });
        }
        // Метод проверки роли админа
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

    }
}
