using Xunit;
using Moq;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using VPTLearn.UnitTests.Interfaces;
using VPTLearn.UnitTests.Models;
using VPTLearn.UnitTests.DTOs;

namespace VPTLearn.UnitTests.Controllers
{
    public class CourseControllerTests
    {
        [Fact]
        public async Task M2_GetAllCourses_Returns200With3CourseDTOs()
        {
            // Arrange
            var mockCourseRepo = new Mock<ICourseRepository>();
            var mockProgressRepo = new Mock<IProgressRepository>();
            
            var courses = new List<Course>
            {
                new Course { Id = 1, Title = "C# Basics", Description = "Learn C#" },
                new Course { Id = 2, Title = "ASP.NET Core", Description = "Web development" },
                new Course { Id = 3, Title = "Entity Framework", Description = "ORM" }
            };
            
            mockCourseRepo.Setup(x => x.GetAllCourses())
                .ReturnsAsync(courses);
                
            mockProgressRepo.Setup(x => x.GetCourseProgress(It.IsAny<int>(), It.IsAny<string>()))
                .ReturnsAsync(50);
            
            var controller = new TestCourseController(
                mockCourseRepo.Object, 
                mockProgressRepo.Object
            );
            
            // Добавляем токен
            var httpContext = new DefaultHttpContext();
            httpContext.Request.Headers["Authorization"] = "Bearer test-token";
            controller.ControllerContext = new ControllerContext 
            { 
                HttpContext = httpContext 
            };
            
            // Act
            var result = await controller.GetAllCourses();
            
            // Assert
            var okResult = result as OkObjectResult;
            okResult.Should().NotBeNull();
            okResult.StatusCode.Should().Be(200);
            
            var dtos = okResult.Value as List<CourseDTO>;
            dtos.Should().NotBeNull();
            dtos.Count.Should().Be(3);
            
            dtos[0].Title.Should().Be("C# Basics");
            dtos[0].Description.Should().Be("Learn C#");
            dtos[0].ProgressPercent.Should().Be(50);
        }
    }

    public class TestCourseController : ControllerBase
    {
        private readonly ICourseRepository _courseRepository;
        private readonly IProgressRepository _progressRepository;

        public TestCourseController(ICourseRepository courseRepository, IProgressRepository progressRepository)
        {
            _courseRepository = courseRepository;
            _progressRepository = progressRepository;
        }

        public async Task<IActionResult> GetAllCourses()
        {
            var courses = await _courseRepository.GetAllCourses();
            var userId = "student-123";
            
            var dtos = new List<CourseDTO>();
            foreach (var course in courses)
            {
                var progress = await _progressRepository.GetCourseProgress(course.Id, userId);
                dtos.Add(new CourseDTO
                {
                    Title = course.Title,
                    Description = course.Description,
                    ProgressPercent = progress
                });
            }
            
            return Ok(dtos);
        }
    }
}