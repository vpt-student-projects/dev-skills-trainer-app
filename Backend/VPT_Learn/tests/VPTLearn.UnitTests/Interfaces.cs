using VPTLearn.UnitTests.Models;

namespace VPTLearn.UnitTests.Interfaces
{
    public interface IAuthService
    {
        Task<(bool Success, string UserId)> RegisterUser(string email, string password);
    }

    public interface IUserRepository
    {
        Task<User> CreateUser(User user);
        Task<User> GetUserById(string id);
    }

    public interface ITokenService
    {
        string GenerateToken(User user);
        string GetUserIdFromToken(string token);
    }

    public interface ICourseRepository
    {
        Task<List<Course>> GetAllCourses();
    }

    public interface IProgressRepository
    {
        Task<int> GetCourseProgress(int courseId, string userId);
        Task<Progress> GetProgress(int userId, int lessonId);
        Task<Progress> UpdateProgress(Progress progress);
    }

    public interface ILessonRepository
    {
        Task<List<Lesson>> GetLessonsByCourseId(int courseId);
    }
}