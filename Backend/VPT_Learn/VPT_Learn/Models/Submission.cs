using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace VPT_Learn.Models
{
    [Table("submissions")]
    public class Submission : BaseModel
    {
        [PrimaryKey("submission_id")]
        public int SubmissionId { get; set; }

        [Column("exercise_id")]
        public int ExerciseId { get; set; }  // FK → code_exercises.id

        [Column("user_id")]
        public int UserId { get; set; }      // FK → users.user_id

        [Column("submitted_code")]
        public string SubmittedCode { get; set; }

        [Column("result")]
        public string Result { get; set; }

        [Column("submitted_at")]
        public DateTime SubmittedAt { get; set; }
        [Column("output")]
        public string? Output { get; set; } // Вывод консоли
        [Column("is_correct")]
        public bool? IsCorrect  { get; set; } 
    }
}

