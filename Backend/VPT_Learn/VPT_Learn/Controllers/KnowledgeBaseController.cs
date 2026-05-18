using Microsoft.AspNetCore.Mvc;
using VPT_Learn.Services;
using Microsoft.AspNetCore.Authorization;
using VPT_Learn.Models;

namespace VPT_Learn.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/knowledgebase")]
    public class KnowledgeBaseController : ControllerBase
    {
        private readonly ISupabaseUserClientFactory _clientFactory;

        public KnowledgeBaseController(ISupabaseUserClientFactory clientFactory)
        {
            _clientFactory = clientFactory;
        }


        [HttpGet("{language}")]
    public async Task<IActionResult> GetInfo(string language)
    {
        try
        {
            var client = await _clientFactory.CreateAsync(HttpContext);
            
            // Используем .Get() вместо .Single() для лучшей обработки
            var result = await client.From<Models.Language>()
                .Filter(n => n.Name, Supabase.Postgrest.Constants.Operator.Equals, language)
                .Get();
            
            // Проверяем, есть ли данные в результате
            if (result == null || result.Models == null || !result.Models.Any())
            {
                return NotFound(new { message = $"Данные для языка '{language}' не найдены в базе" });
            }
            
            var data = result.Models.FirstOrDefault();
            
            // Дополнительная проверка на null
            if (data == null)
            {
                return NotFound(new { message = $"Данные для языка '{language}' не найдены в базе" });
            }

            return Ok(new
            {
                name = data.Name,
                description = data.Description
            });
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