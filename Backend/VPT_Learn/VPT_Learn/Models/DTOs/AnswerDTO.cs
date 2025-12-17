using Supabase.Postgrest.Attributes;

namespace VPT_Learn.Models
{
    public class AnswerDTO
    {
        public long Id { get; set; }


        public int ExerciseId { get; set; }

        public string Answer { get; set; }
    }
}
