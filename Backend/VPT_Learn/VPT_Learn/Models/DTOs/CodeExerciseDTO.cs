
namespace VPT_Learn.Models
{

        public class CodeExerciseDTO 
        {
            public long Id { get; set; }     // FK → lessons.lesson_id (1:1)

            public DateTime CreatedAt { get; set; }

            public string? Code { get; set; }

            public string? TaskDescription { get; set; }
        }

}
