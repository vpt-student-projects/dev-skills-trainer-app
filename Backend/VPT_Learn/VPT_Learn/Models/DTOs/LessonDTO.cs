using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace VPT_Learn.Models
{

    public class LessonDTO : BaseModel
    {

        public int LessonId { get; set; }


        public int CourseId { get; set; }    // FK → courses.course_id


        public string Title { get; set; }


        public string? Content { get; set; }


        public int OrderIndex { get; set; }
    }
}