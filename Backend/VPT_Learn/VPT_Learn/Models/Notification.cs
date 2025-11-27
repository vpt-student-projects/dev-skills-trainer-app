using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace VPT_Learn.Models
{
    [Table("notifications")]
    public class Notification : BaseModel
    {
        [PrimaryKey("notification_id")]
        public int NotificationId { get; set; }

        [Column("user_id")]
        public int UserId { get; set; }   // FK → users.user_id

        [Column("message")]
        public string Message { get; set; }

        [Column("type")]
        public string? Type { get; set; }  // системное / учебное / достижение

        [Column("created_at")]
        public DateTime? CreatedAt { get; set; }

        [Column("read_status")]
        public bool? ReadStatus { get; set; }
    }

}
