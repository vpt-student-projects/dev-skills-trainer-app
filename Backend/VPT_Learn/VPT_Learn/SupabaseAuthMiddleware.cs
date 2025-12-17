public class SupabaseAuthMiddleware
{
    private readonly RequestDelegate _next;

    public SupabaseAuthMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var authHeader = context.Request.Headers["Authorization"].FirstOrDefault();
        var refreshHeader = context.Request.Headers["X-Refresh-Token"].FirstOrDefault();

        if (!string.IsNullOrEmpty(authHeader) && authHeader.StartsWith("Bearer "))
        {
            var accessToken = authHeader.Substring("Bearer ".Length).Trim();
            context.Items["SupabaseAccessToken"] = accessToken;
            context.Items["SupabaseRefreshToken"] = refreshHeader; // сохраняем refresh token
        }

        await _next(context);
    }
}
