using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace VPT_Learn.Models
{
    [Table("progress")]
    public class Progress : BaseModel
    {
        [PrimaryKey("progress_id")]
        public int ProgressId { get; set; }

        [Column("user_id")]
        public int UserId { get; set; }     // FK → users.user_id

        [Column("course_id")]
        public int CourseId { get; set; }   // FK → courses.course_id

        [Column("completed_lessons")]
        public int? CompletedLessons { get; set; }

        [Column("score")]
        public int? Score { get; set; }

        [Column("last_activity")]
        public DateTime? LastActivity { get; set; }
    }

}
