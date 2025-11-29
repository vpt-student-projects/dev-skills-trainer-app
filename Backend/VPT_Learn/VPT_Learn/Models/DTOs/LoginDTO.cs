using Supabase.Postgrest.Models;

namespace VPT_Learn.Models
{

        public class LoginDTO : BaseModel
        {
            public string Email { get; set; }
            public string Password { get; set; }
        }
    
}
