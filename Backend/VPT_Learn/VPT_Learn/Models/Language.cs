using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace VPT_Learn.Models
{
    [Table("knowledge_base")]
    public class Language : BaseModel
    {
        [PrimaryKey("id")]
        public long Id { get; set; }
        
        [Column("created_at")]
        public DateTime CreatedAt { get; set; }
        
        [Column("name")]  // <- Убедитесь, что атрибут указан
        public string Name { get; set; }
        
        [Column("description")]  // <- Убедитесь, что атрибут указан
        public string Description { get; set; }
    }
}