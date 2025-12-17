using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace VPT_Learn.Models
{
    [Table("answers")]
    public class AnswerClass : BaseModel
    {
        [PrimaryKey("id")]
        public long Id { get; set; }

        [Column("exercise_id")]
        public int ExerciseId { get; set; }

        [Column("answer")]
        public string? Answer { get; set; }  // <-- совпадает с названием колонки

        // если используете BaseModel, иногда нужно явно отключить поля времени:
        // [Column("created_at")] public DateTime? CreatedAt { get; set; }
        // [Column("updated_at")] public DateTime? UpdatedAt { get; set; }
    }
}
