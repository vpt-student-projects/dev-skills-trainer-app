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

    [HttpPost("update-user-auth")]
    public async Task<IActionResult> AdminUpdateUserAuth(
    [FromBody] AdminUpdateUserRequest request)
        {
            var userClient = await _clientFactory.CreateAsync(HttpContext);
            if (userClient == null) return Unauthorized();

            if (!await IsAdmin(userClient))
                return StatusCode(403, "Admin privileges required");

            if (string.IsNullOrWhiteSpace(request.NewEmail) &&
                string.IsNullOrWhiteSpace(request.NewPassword))
                return BadRequest("Nothing to update");

            // ===== 1. Обновляем AUTH (email / password) =====
            var adminAuthClient =
                userClient.AdminAuth(
                    Environment.GetEnvironmentVariable("SUPABASE_SERVICE_ROLE_KEY")!
                );

            var authAttrs = new Supabase.Gotrue.AdminUserAttributes();

            if (!string.IsNullOrWhiteSpace(request.NewEmail))
                authAttrs.Email = request.NewEmail;

            if (!string.IsNullOrWhiteSpace(request.NewPassword))
            {
                if (request.NewPassword.Length < 6)
                    return BadRequest("Password too short");

                authAttrs.Password = request.NewPassword;
            }

            var authResult = await adminAuthClient.UpdateUserById(
                request.UserUuid.ToString(),
                authAttrs
            );

            if (authResult == null)
                return StatusCode(500, "Failed to update auth user");

            // ===== 2. Обновляем public.users (ТОЛЬКО email) =====
            if (!string.IsNullOrWhiteSpace(request.NewEmail))
            {
                var adminDbClient = SupabaseAdmin.Create();

                var updateResult = await adminDbClient
                    .From<Models.User>()
                    .Filter("user_uuid", Supabase.Postgrest.Constants.Operator.Equals, request.UserUuid.ToString())
                    .Set(u => u.Email, request.NewEmail)
                    .Update();


                if (updateResult == null)
                    return StatusCode(500, "Failed to update public user");
            }

            return Ok(new
            {
                message = "User updated successfully",
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
