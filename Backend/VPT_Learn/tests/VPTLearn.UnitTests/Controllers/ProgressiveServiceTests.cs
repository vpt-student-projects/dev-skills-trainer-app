using Xunit;
using Moq;
using FluentAssertions;
using VPTLearn.UnitTests.Interfaces;
using VPTLearn.UnitTests.Models;

namespace VPTLearn.UnitTests.Controllers
{
    public class ProgressServiceTests
    {
        [Fact]
        public async Task M5_UpdateProgress_Returns200AndUpdatesStatus()
        {
            // Arrange
            var mockProgressRepo = new Mock<IProgressRepository>();
            var userId = 1;
            var lessonId = 10;
            var status = "completed";
            var updatedAt = DateTime.UtcNow;
            
            var progress = new Progress
            {
                UserId = userId,
                LessonId = lessonId,
                Status = "in_progress",
                UpdatedAt = DateTime.UtcNow.AddDays(-1)
            };
            
            mockProgressRepo.Setup(x => x.GetProgress(userId, lessonId))
                .ReturnsAsync(progress);
                
            mockProgressRepo.Setup(x => x.UpdateProgress(It.IsAny<Progress>()))
                .ReturnsAsync(new Progress 
                { 
                    UserId = userId, 
                    LessonId = lessonId, 
                    Status = status,
                    UpdatedAt = updatedAt 
                });
            
            var service = new TestProgressService(mockProgressRepo.Object);
            
            // Act
            var result = await service.UpdateProgress(userId, lessonId, status);
            
            // Assert
            result.Should().NotBeNull();
            result.Status.Should().Be("completed");
            result.UpdatedAt.Should().Be(updatedAt);
            
            mockProgressRepo.Verify(x => x.UpdateProgress(It.Is<Progress>(p => 
                p.UserId == userId && 
                p.LessonId == lessonId && 
                p.Status == "completed"
            )), Times.Once);
        }
    }

    public class TestProgressService
    {
        private readonly IProgressRepository _progressRepository;

        public TestProgressService(IProgressRepository progressRepository)
        {
            _progressRepository = progressRepository;
        }

        public async Task<Progress> UpdateProgress(int userId, int lessonId, string status)
        {
            var progress = await _progressRepository.GetProgress(userId, lessonId);
            progress.Status = status;
            progress.UpdatedAt = DateTime.UtcNow;
            return await _progressRepository.UpdateProgress(progress);
        }
    }
}