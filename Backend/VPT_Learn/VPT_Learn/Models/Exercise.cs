using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace VPT_Learn.Models
{
    [Table("exercises")]
    public class Exercise : BaseModel
    {
        [PrimaryKey("exercise_id")]
        public int ExerciseId { get; set; }

        [Column("lesson_id")]
        public int LessonId { get; set; }   // FK → lessons.lesson_id

        [Column("task_description")]
        public string TaskDescription { get; set; }

        [Column("right_answer")]
        public string? RightAnswer { get; set; }

        [Column("answer_1")]
        public string? Answer1 { get; set; }

        [Column("answer_2")]
        public string? Answer2 { get; set; }

        [Column("answer_3")]
        public string? Answer3 { get; set; }

        [Column("answer_4")]
        public string? Answer4 { get; set; }
    }

}
