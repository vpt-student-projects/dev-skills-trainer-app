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
        private readonly IConfiguration _config;

        public SupabaseUserClientFactory(IConfiguration config)
        {
            _config = config;
        }
        public async Task<Client> CreateAsync(HttpContext httpContext)
        {
            var token = httpContext.Items["SupabaseAccessToken"] as string;

            if (string.IsNullOrWhiteSpace(token))
                throw new UnauthorizedAccessException("Bearer token missing");

            var options = new SupabaseOptions
            {
                AutoConnectRealtime = false,
                Headers = new Dictionary<string, string>
                {
                    { "Authorization", $"Bearer {token}" }
                }
            };

            var client = new Client(
                Environment.GetEnvironmentVariable("SUPABASE_URL"),
                Environment.GetEnvironmentVariable("SUPABASE_KEY"),
                options
            );

            await client.InitializeAsync();
            return client;
        }
    }
}
