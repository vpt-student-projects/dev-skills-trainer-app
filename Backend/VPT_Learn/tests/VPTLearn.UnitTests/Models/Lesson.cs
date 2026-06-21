namespace VPTLearn.UnitTests.Models
{
    public class Lesson
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public int Order { get; set; }
        public string Content { get; set; } = string.Empty;
        public int CourseId { get; set; }
    }
}