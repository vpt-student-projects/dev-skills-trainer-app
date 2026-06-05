using Microsoft.AspNetCore.Mvc;
using VPT_Learn.Services;
using Microsoft.AspNetCore.Authorization;
using VPT_Learn.Models;

namespace VPT_Learn.Controllers
{
    //[Authorize]
    [ApiController]
    [Route("api/knowledgebase")]
    public class KnowledgeBaseController : ControllerBase
    {
        private readonly ISupabaseUserClientFactory _clientFactory;

        public KnowledgeBaseController(ISupabaseUserClientFactory clientFactory)
        {
            _clientFactory = clientFactory;
        }


        [HttpGet]
    public async Task<IActionResult> GetInfo()
    {
        try
        {
            var client = await _clientFactory.CreateAsync(HttpContext);
            
            // Используем .Get() вместо .Single() для лучшей обработки
            var result = await client.From<Models.Language>().Get();
            
            // Проверяем, есть ли данные в результате
            if (result == null || result.Models == null || !result.Models.Any())
            {
                return NotFound(new { message = $"Данные для языков не найдены в базе" });
            }
            
              var languagedata = result.Models.Select(e => new LanguageDTO
                {
                    Id = e.Id,
                    Name = e.Name,
                    Description = e.Description,
                    Features = e.Features,
                    Example = e.Example,
                    CreatedAt = e.CreatedAt
                });
                    
                
            
            // Дополнительная проверка на null
            if (languagedata == null)
            {
                return NotFound(new { message = $"Данные для языка '{languagedata}' не найдены в базе" });
            }

            return Ok(new { languagedata });
        }
        catch (Exception ex)
        {
            // Логируем исключение для отладки
            // _logger.LogError(ex, "Ошибка при получении данных для языка {Language}", language);
            
            return StatusCode(500, new { message = "Внутренняя ошибка сервера", error = ex.Message });
        }
    }
    }
}