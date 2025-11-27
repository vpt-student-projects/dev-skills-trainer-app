using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace VPT_Learn.Models
{
    [Table("lessons")]
    public class Lesson : BaseModel
    {
        [PrimaryKey("lesson_id")]
        public int LessonId { get; set; }

        [Column("course_id")]
        public int CourseId { get; set; }    // FK → courses.course_id

        [Column("title")]
        public string Title { get; set; }

        [Column("content")]
        public string? Content { get; set; }

        [Column("order_index")]
        public int OrderIndex { get; set; }
    }
}