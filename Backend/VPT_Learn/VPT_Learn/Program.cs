
using Supabase;
using DotNetEnv;
using static Supabase.Postgrest.Constants;
namespace VPT_Learn
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.
            Env.Load();
            builder.Services.AddControllers();
            // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();
            builder.Configuration.AddEnvironmentVariables();
            var url = Environment.GetEnvironmentVariable("SUPABASE_URL");
            var key = Environment.GetEnvironmentVariable("SUPABASE_KEY");
            builder.Services.AddScoped<Supabase.Client>(_ =>
                new Supabase.Client(url,key,
                    new SupabaseOptions
                    {
                        AutoRefreshToken = true,
                        AutoConnectRealtime = true
                    }));
            var app = builder.Build();

            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())
            {
                app.UseSwagger();
                app.UseSwaggerUI();
            }

            app.MapGet("/users/{id}", async (Supabase.Client client, int id) =>
            {
                var user = await client
                    .From<Models.User>()
                    .Select("*")
                    .Filter("user_uuid", Operator.Equals, client.Auth.CurrentSession.User.Id)
                    .Single();

                return Results.Ok(user);
            });

            app.UseHttpsRedirection();

            app.UseAuthorization();


            app.MapControllers();

            app.Run();
        }
    }
}
