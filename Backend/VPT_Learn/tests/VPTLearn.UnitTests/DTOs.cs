namespace VPTLearn.UnitTests.DTOs
{
    public class RegisterResponse
    {
        public string UserId { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string AccessToken { get; set; } = string.Empty;
    }

    public class CourseDTO
    {
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public int ProgressPercent { get; set; }
    }

    public class UserDTO
    {
        public string Email { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
    }

    public class LessonDTO
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public int Order { get; set; }
        public string Content { get; set; } = string.Empty;
    }
}