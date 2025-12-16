using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace VPT_Learn.Models
{
    [Table("answers")]
    public class Answer : BaseModel
    {
        [PrimaryKey("id")]
        public long Id { get; set; }

        [Column("exercise_id")]
        public int ExerciseId { get; set; }

        [Column("answer")]
        public string AnswerText { get; set; }
    }
}
