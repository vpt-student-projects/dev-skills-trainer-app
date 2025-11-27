using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace VPT_Learn.Models
{
    
    public class UserDTO : BaseModel
    {

        public int UserId { get; set; }

        public string Name { get; set; }

        public string Email { get; set; }

        public string PasswordHash { get; set; }

        public string Role { get; set; }   // студент / преподаватель / админ

        public DateTime? CreatedAt { get; set; }

        public Guid? UserUuid { get; set; }   // FK → auth.users.id
    }

}
