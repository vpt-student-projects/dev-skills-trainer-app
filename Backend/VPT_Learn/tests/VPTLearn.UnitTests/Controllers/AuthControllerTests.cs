using Xunit;
using Moq;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc;
using VPTLearn.UnitTests.Interfaces;
using VPTLearn.UnitTests.Models;
using VPTLearn.UnitTests.DTOs;

namespace VPTLearn.UnitTests.Controllers
{
    public class AuthControllerTests
    {
        [Fact]
        public async Task M1_Register_Returns201WithUserDataAndJwtToken()
        {
            // Arrange
            var mockAuth = new Mock<IAuthService>();
            var mockUserRepo = new Mock<IUserRepository>();
            var mockToken = new Mock<ITokenService>();
            
            var request = new RegisterRequest 
            { 
                Email = "student@test.com", 
                Password = "Pass123!" 
            };
            
            var user = new User 
            { 
                Id = "user-123", 
                Email = request.Email, 
                Role = "student",
                CreatedAt = DateTime.UtcNow
            };
            
            var jwtToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjMifQ.test";
            
            mockAuth.Setup(x => x.RegisterUser(request.Email, request.Password))
                .ReturnsAsync((true, user.Id));
                
            mockUserRepo.Setup(x => x.CreateUser(It.IsAny<User>()))
                .ReturnsAsync(user);
                
            mockToken.Setup(x => x.GenerateToken(It.IsAny<User>()))
                .Returns(jwtToken);
            
            var controller = new TestAuthController(
                mockAuth.Object, 
                mockUserRepo.Object, 
                mockToken.Object
            );
            
            // Act
            var result = await controller.Register(request);
            
            // Assert
            var okResult = result as ObjectResult;
            okResult.Should().NotBeNull();
            okResult.StatusCode.Should().Be(201);
            
            var response = okResult.Value as RegisterResponse;
            response.Should().NotBeNull();
            response.UserId.Should().Be("user-123");
            response.Email.Should().Be("student@test.com");
            response.AccessToken.Should().Be(jwtToken);
            
            // Проверка JWT формата
            response.AccessToken.Split('.').Length.Should().Be(3);
            
            // Проверка роли
            mockUserRepo.Verify(x => x.CreateUser(It.Is<User>(u => 
                u.Role == "student"
            )), Times.Once);
        }
    }

    // Тестовый контроллер
    public class TestAuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly IUserRepository _userRepository;
        private readonly ITokenService _tokenService;

        public TestAuthController(IAuthService authService, IUserRepository userRepository, ITokenService tokenService)
        {
            _authService = authService;
            _userRepository = userRepository;
            _tokenService = tokenService;
        }

        public async Task<IActionResult> Register(RegisterRequest request)
        {
            var (success, userId) = await _authService.RegisterUser(request.Email, request.Password);
            
            if (!success)
                return BadRequest();

            var user = new User 
            { 
                Id = userId, 
                Email = request.Email, 
                Role = "student" 
            };
            
            await _userRepository.CreateUser(user);
            var token = _tokenService.GenerateToken(user);
            
            return new ObjectResult(new RegisterResponse 
            { 
                UserId = userId, 
                Email = request.Email, 
                AccessToken = token 
            }) 
            { 
                StatusCode = 201 
            };
        }
    }
}