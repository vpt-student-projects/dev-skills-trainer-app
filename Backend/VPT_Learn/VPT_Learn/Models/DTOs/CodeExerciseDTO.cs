using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace VPT_Learn.Models
{

        public class CodeExerciseDTO : BaseModel
        {
            public long Id { get; set; }     // FK → lessons.lesson_id (1:1)

            public DateTime CreatedAt { get; set; }

            public string? Code { get; set; }

            public string? TaskDescription { get; set; }
        }

}
