using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace VPT_Learn.Models
{

    public class NotificationDTO : BaseModel
    {

        public int NotificationId { get; set; }


        public int UserId { get; set; }   // FK → users.user_id


        public string Message { get; set; }


        public string? Type { get; set; }  // системное / учебное / достижение


        public DateTime? CreatedAt { get; set; }


        public bool? ReadStatus { get; set; }
    }

}
