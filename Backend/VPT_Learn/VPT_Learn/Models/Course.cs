using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;
namespace VPT_Learn.Models
{
    [Table("courses")]
    public class Course : BaseModel
    {
        [PrimaryKey("course_id")]
        public int CourseId { get; set; }

        [Column("title")]
        public string? Title { get; set; }

        [Column("description")]
        public string? Description { get; set; }

        [Column("language")]
        public string Language { get; set; }

        [Column("level")]
        public string Level { get; set; }   // начальный / средний / продвинутый

        [Column("created_by")]
        public int CreatedBy { get; set; }  // FK → users.user_id
    }

}