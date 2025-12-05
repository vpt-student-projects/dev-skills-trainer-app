using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace VPT_Learn.Models
{
        [Table("code_exercises")]
        public class CodeExercise : BaseModel
        {
            [PrimaryKey("id")]
            public long Id { get; set; }     // FK → lessons.lesson_id (1:1)

            [Column("created_at")]
            public DateTime CreatedAt { get; set; }

            [Column("code")]
            public string? Code { get; set; }

            [Column("task_description")]
            public string? TaskDescription { get; set; }
            [Column("exercise_id")]
            public string? ExerciseId { get; set; }
        }
}
