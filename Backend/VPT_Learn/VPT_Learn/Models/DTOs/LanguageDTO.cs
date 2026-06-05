using System.Text.Json.Serialization;

namespace VPT_Learn.Models
{
    public class LanguageDTO
    {
        public int Id { get; set; }
        
        [JsonPropertyName("created_at")]
        public DateTime? CreatedAt { get; set; }
        
        public string Name { get; set; }
        public string? Description { get; set; }
        public string? Features { get; set; }
        public string? Example { get; set; }
    }
}