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
        [Column("order_index")]
        public int OrderIndex { get; set; }

        [Column("type")]
        public string Type { get; set; }

        // Для DTO: список всех ответов
        public List<AnswerClass> Answers { get; set; }
    }
}
