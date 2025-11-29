using Supabase.Postgrest.Models;

namespace VPT_Learn.Models
{

        public class RegisterDTO : BaseModel
    
        {
            public string Email { get; set; }
            public string Password { get; set; }
        }
    
}
