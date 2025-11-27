using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace VPT_Learn.Models
{
    [Table("users")]
    public class User : BaseModel
    {
        [PrimaryKey("user_id")]
        public int UserId { get; set; }

        [Column("name")]
        public string Name { get; set; }

        [Column("email")]
        public string Email { get; set; }

        [Column("password_hash")]
        public string PasswordHash { get; set; }

        [Column("role")]
        public string Role { get; set; }   // студент / преподаватель / админ

        [Column("created_at")]
        public DateTime? CreatedAt { get; set; }

        [Column("user_uuid")]
        public Guid? UserUuid { get; set; }   // FK → auth.users.id
    }

}
