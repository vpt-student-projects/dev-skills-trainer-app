namespace VPTLearn.UnitTests.Models
{
    public class Progress
    {
        public int UserId { get; set; }
        public int LessonId { get; set; }
        public string Status { get; set; } = string.Empty;
        public DateTime UpdatedAt { get; set; }
    }
}