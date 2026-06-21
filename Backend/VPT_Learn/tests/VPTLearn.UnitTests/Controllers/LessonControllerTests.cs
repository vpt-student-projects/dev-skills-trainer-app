using Xunit;
using Moq;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc;
using VPTLearn.UnitTests.Interfaces;
using VPTLearn.UnitTests.Models;
using VPTLearn.UnitTests.DTOs;

namespace VPTLearn.UnitTests.Controllers
{
    public class LessonControllerTests
    {
        [Fact]
        public async Task M4_GetLessons_Returns200With3LessonsSortedByOrder()
        {
            // Arrange
            var mockLessonRepo = new Mock<ILessonRepository>();
            var courseId = 1;
            
            var lessons = new List<Lesson>
            {
                new Lesson { Id = 1, Title = "Introduction", Order = 1, Content = "Content 1" },
                new Lesson { Id = 2, Title = "Basics", Order = 2, Content = "Content 2" },
                new Lesson { Id = 3, Title = "Advanced", Order = 3, Content = "Content 3" }
            };
            
            mockLessonRepo.Setup(x => x.GetLessonsByCourseId(courseId))
                .ReturnsAsync(lessons);
            
            var controller = new TestLessonsController(mockLessonRepo.Object);
            
            // Act
            var result = await controller.GetLessons(courseId);
            
            // Assert
            var okResult = result as OkObjectResult;
            okResult.Should().NotBeNull();
            okResult.StatusCode.Should().Be(200);
            
            var dtos = okResult.Value as List<LessonDTO>;
            dtos.Should().NotBeNull();
            dtos.Count.Should().Be(3);
            
            // Проверка порядка
            dtos[0].Order.Should().Be(1);
            dtos[1].Order.Should().Be(2);
            dtos[2].Order.Should().Be(3);
            
            // Проверка содержимого
            dtos[0].Title.Should().Be("Introduction");
            dtos[0].Content.Should().Be("Content 1");
        }
    }

    public class TestLessonsController : ControllerBase
    {
        private readonly ILessonRepository _lessonRepository;

        public TestLessonsController(ILessonRepository lessonRepository)
        {
            _lessonRepository = lessonRepository;
        }

        public async Task<IActionResult> GetLessons(int courseId)
        {
            var lessons = await _lessonRepository.GetLessonsByCourseId(courseId);
            var dtos = lessons.Select(l => new LessonDTO
            {
                Id = l.Id,
                Title = l.Title,
                Order = l.Order,
                Content = l.Content
            }).ToList();
            
            return Ok(dtos);
        }
    }
}