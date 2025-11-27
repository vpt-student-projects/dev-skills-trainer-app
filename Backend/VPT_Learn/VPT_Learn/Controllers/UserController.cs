using Microsoft.AspNetCore.Mvc;
using Supabase;
using VPT_Learn.Models;

namespace VPT_Learn.Controllers
{
    [ApiController]
    [Route("api/user")]
    public class UserController : ControllerBase
    {
        private readonly Supabase.Client _client;

        public UserController(Supabase.Client client)
        {
            _client = client;
        }

        [HttpGet("current")]
        public async Task<IActionResult> Current()
        {
            var session = _client.Auth.CurrentSession;

            if (session == null)
                return Unauthorized("Нет активной сессии");

            var uid = session.User.Id;

            var user = await _client
                .From<User>()
                .Select("*")
                .Filter("user_uuid", Supabase.Postgrest.Constants.Operator.Equals, uid)
                .Single();

            return Ok(user);
        }
    }
}
