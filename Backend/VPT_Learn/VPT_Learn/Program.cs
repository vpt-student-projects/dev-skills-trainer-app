
using Supabase;
using DotNetEnv;
using static Supabase.Postgrest.Constants;
using Microsoft.OpenApi.Models;
using VPT_Learn.Controllers;
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
            builder.Services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new OpenApiInfo
                {
                    Title = "My Supabase API",
                    Version = "v1",
                    Description = "API � �������������� ��������������� Supabase"
                });

                // ��������� ������������ JWT � Swagger
                c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
                {
                    Description = "JWT Authorization header using the Bearer scheme",
                    Name = "Authorization",
                    In = ParameterLocation.Header,
                    Type = SecuritySchemeType.ApiKey,
                    Scheme = "Bearer"
                });

                c.AddSecurityRequirement(new OpenApiSecurityRequirement
                {
                    {
                        new OpenApiSecurityScheme
                        {
                            Reference = new OpenApiReference
                            {
                                Type = ReferenceType.SecurityScheme,
                                Id = "Bearer",
                                
                                
                            }
                        },
                        new string[] { "Bearer " }
                    }
                });

                // �������� XML �����������
//c.IncludeXmlComments(Path.Combine(AppContext.BaseDirectory, "VPT_Learn.xml"));
            });
            builder.Configuration.AddEnvironmentVariables();
            var url = Environment.GetEnvironmentVariable("SUPABASE_URL");
            var key = Environment.GetEnvironmentVariable("SUPABASE_KEY");

            builder.Services.AddSingleton<Supabase.Client>(_ =>
                new Supabase.Client(url,key,
                    new SupabaseOptions
                    {
                        AutoRefreshToken = true,
                        AutoConnectRealtime = true
                    }));
            builder.Services.AddScoped<ISupabaseUserClientFactory, SupabaseUserClientFactory>();

            var app = builder.Build();
            app.UseMiddleware<SupabaseAuthMiddleware>();

            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())
            {
                app.UseSwagger();
                app.UseSwaggerUI();
            }
            app.UseSwagger(c =>
            {
                c.RouteTemplate = "swagger/{documentName}/swagger.json";
            });
            app.UseSwaggerUI(c =>
            {
                c.SwaggerEndpoint("/swagger/v1/swagger.json", "My API V1");
                c.RoutePrefix = string.Empty; // Swagger UI �������� �� ��������� URL
            });
            //app.UseHttpsRedirection();
            app.UseRouting();
            app.UseAuthorization();


            app.MapControllers();

            app.Run();
        }
    }
}
