using Microsoft.AspNetCore.Mvc;

namespace VPT_Learn.Controllers
{
    public abstract class SupabaseController : ControllerBase
    {
        protected Supabase.Client Client =>
            HttpContext.Items["Supabase"] as Supabase.Client
                ?? throw new Exception("No session. Send Authorization Bearer token.");
    }
}
