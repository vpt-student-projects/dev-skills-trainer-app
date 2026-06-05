using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace VPT_Learn.Models
{
    [Table("knowledge_base")]
    public class Language : BaseModel
    {
        [PrimaryKey("id")]
        public int Id { get; set; }
        
        [Column("created_at")]
        public DateTime CreatedAt { get; set; }
        
        [Column("name")]
        public string Name { get; set; }
        
        [Column("description")]
        public string Description { get; set; }
        
        [Column("features")]
        public string Features { get; set; }
        
        [Column("example")]
        public string Example { get; set; }
    }
}