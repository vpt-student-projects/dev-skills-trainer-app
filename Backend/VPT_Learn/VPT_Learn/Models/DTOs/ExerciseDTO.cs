using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace VPT_Learn.Models
{

    public class ExerciseDTO : BaseModel
    {

        public int ExerciseId { get; set; }


        public int LessonId { get; set; }   // FK → lessons.lesson_id

        public string TaskDescription { get; set; }


        public string? RightAnswer { get; set; }

    }


}
