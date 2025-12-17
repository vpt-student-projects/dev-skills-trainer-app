using Microsoft.AspNetCore.Mvc;
using Supabase;

namespace VPT_Learn.Controllers
{
    public interface ISupabaseUserClientFactory // todo перенести отдельно
    {
        Task<Supabase.Client> CreateAsync(HttpContext httpContext);
    }


    public class SupabaseUserClientFactory : ISupabaseUserClientFactory
    {


        private readonly string _supabaseUrl = Environment.GetEnvironmentVariable("SUPABASE_URL");
        private readonly string _anonKey = Environment.GetEnvironmentVariable("SUPABASE_KEY");

        public async Task<Client> CreateAsync(HttpContext httpContext)
        {
            var token = httpContext.Items["SupabaseAccessToken"] as string;
            var refresh = httpContext.Items["SupabaseRefreshToken"] as string;

            if (string.IsNullOrWhiteSpace(token) || string.IsNullOrWhiteSpace(refresh))
                throw new UnauthorizedAccessException("Bearer or refresh token missing");

            var options = new SupabaseOptions
            {
                AutoRefreshToken = true,      // автоматически обновляет токен при истечении
                AutoConnectRealtime = true,
                Headers = new Dictionary<string, string>
            {
                { "Authorization", $"Bearer {token}" }  // JWT пользователя
            }
            };

            var client = new Client(_supabaseUrl, _anonKey, options);
            await client.InitializeAsync();
            // Устанавливаем текущую сессию пользователя по JWT
            await client.Auth.SetSession(token, refresh);
            return client;
        }


    }
}
