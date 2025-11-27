using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;
namespace VPT_Learn.Models
{

    public class CourseDTO : BaseModel
    {
        public int CourseId { get; set; }


        public string Title { get; set; }


        public string? Description { get; set; }


        public string Language { get; set; }

        public string Level { get; set; }   // начальный / средний / продвинутый

 
        public int CreatedBy { get; set; }  // FK → users.user_id
    }
}