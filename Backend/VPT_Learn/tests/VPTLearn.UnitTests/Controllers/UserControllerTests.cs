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
    public class UserControllerTests
    {
        [Fact]
        public async Task M3_CurrentUser_Returns200WithUserDTO()
        {
            // Arrange
            var mockUserRepo = new Mock<IUserRepository>();
            var mockToken = new Mock<ITokenService>();
            
            var user = new User
            {
                Id = "user-123",
                Email = "student@test.com",
                Role = "student",
                CreatedAt = new DateTime(2024, 1, 15)
            };
            
            mockToken.Setup(x => x.GetUserIdFromToken(It.IsAny<string>()))
                .Returns("user-123");
                
            mockUserRepo.Setup(x => x.GetUserById("user-123"))
                .ReturnsAsync(user);
            
            // Создаем тестовый контроллер
            var controller = new TestUserController(mockUserRepo.Object, mockToken.Object);
            
            // Добавляем Bearer токен
            var httpContext = new DefaultHttpContext();
            httpContext.Request.Headers["Authorization"] = "Bearer valid-token";
            controller.ControllerContext = new ControllerContext 
            { 
                HttpContext = httpContext 
            };
            
            // Act
            var result = await controller.CurrentUser();
            
            // Assert
            var okResult = result as OkObjectResult;
            okResult.Should().NotBeNull();
            okResult.StatusCode.Should().Be(200);
            
            var dto = okResult.Value as UserDTO;
            dto.Should().NotBeNull();
            dto.Email.Should().Be("student@test.com");
            dto.Role.Should().Be("student");
            dto.CreatedAt.Should().Be(new DateTime(2024, 1, 15));
            
            // Данные из мока совпадают 100%
            dto.Email.Should().Be(user.Email);
            dto.Role.Should().Be(user.Role);
            dto.CreatedAt.Should().Be(user.CreatedAt);
        }

        [Fact]
        public async Task M3_CurrentUser_UserNotFound_Returns404()
        {
            // Arrange
            var mockUserRepo = new Mock<IUserRepository>();
            var mockToken = new Mock<ITokenService>();
            
            mockToken.Setup(x => x.GetUserIdFromToken(It.IsAny<string>()))
                .Returns("user-999");
                
            mockUserRepo.Setup(x => x.GetUserById("user-999"))
                .ReturnsAsync((User)null!);
            
            var controller = new TestUserController(mockUserRepo.Object, mockToken.Object);
            
            var httpContext = new DefaultHttpContext();
            httpContext.Request.Headers["Authorization"] = "Bearer valid-token";
            controller.ControllerContext = new ControllerContext 
            { 
                HttpContext = httpContext 
            };
            
            // Act
            var result = await controller.CurrentUser();
            
            // Assert
            var notFoundResult = result as NotFoundResult;
            notFoundResult.Should().NotBeNull();
            notFoundResult.StatusCode.Should().Be(404);
        }
    }

    // Тестовый контроллер (замените на ваш реальный контроллер)
    public class TestUserController : ControllerBase
    {
        private readonly IUserRepository _userRepository;
        private readonly ITokenService _tokenService;

        public TestUserController(IUserRepository userRepository, ITokenService tokenService)
        {
            _userRepository = userRepository;
            _tokenService = tokenService;
        }

        public async Task<IActionResult> CurrentUser()
        {
            // Получаем токен из заголовка
            var authHeader = Request.Headers["Authorization"].ToString();
            if (string.IsNullOrEmpty(authHeader) || !authHeader.StartsWith("Bearer "))
            {
                return Unauthorized();
            }

            var token = authHeader.Replace("Bearer ", "");
            var userId = _tokenService.GetUserIdFromToken(token);
            
            if (string.IsNullOrEmpty(userId))
            {
                return Unauthorized();
            }

            var user = await _userRepository.GetUserById(userId);
            
            if (user == null)
            {
                return NotFound();
            }

            var dto = new UserDTO
            {
                Email = user.Email,
                Role = user.Role,
                CreatedAt = user.CreatedAt
            };

            return Ok(dto);
        }
    }
}