using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json.Linq;
using Supabase.Gotrue;

public class SupabaseAuthMiddleware
{
    private readonly RequestDelegate _next;

    public SupabaseAuthMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context, [FromServices] Supabase.Client supabase)
    {
        var authHeader = context.Request.Headers["Authorization"].FirstOrDefault();

        if (!string.IsNullOrEmpty(authHeader))
        {
            string token = "";
            if (authHeader.StartsWith("Bearer "))
            {
                token = authHeader.Substring("Bearer ".Length).Trim();
            }
            else
            {
                token = authHeader.Trim();
            }

            try
            {
                // Проверка токена через Supabase
                var user = await supabase.Auth.GetUser(token);
                if (user != null)
                {
                    context.Items["SupabaseUser"] = user;
                }
            }
            catch (Exception ex)
            {
                // Логирование ошибки авторизации
                Console.WriteLine($"Auth error: {ex.Message}");
            }
        }


        await _next(context);
    }
}


