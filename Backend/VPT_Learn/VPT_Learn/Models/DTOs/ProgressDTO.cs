

namespace VPT_Learn.Models
{

    public class ProgressDTO 
    {

        public int ProgressId { get; set; }


        public int UserId { get; set; }     // FK → users.user_id


        public int CourseId { get; set; }   // FK → courses.course_id

        public int? CompletedLessons { get; set; }


        public int? Score { get; set; }


        public DateTime? LastActivity { get; set; }
    }

}
