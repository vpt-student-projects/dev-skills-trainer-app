
using Supabase;
using DotNetEnv;
using static Supabase.Postgrest.Constants;
using Microsoft.OpenApi.Models;
using VPT_Learn.Controllers;

using Microsoft.IdentityModel.Tokens;
using Microsoft.AspNetCore.Authentication.JwtBearer;
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


            builder.Services
                .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
                .AddJwtBearer(options =>
                {
                    options.TokenValidationParameters = new TokenValidationParameters
                    {
                        ValidateIssuer = true,
                        ValidIssuer = "https://urenfyjdtjfffstsaymu.supabase.co/auth/v1",

                        ValidateAudience = true,
                        ValidAudience = "authenticated",

                        ValidateLifetime = true,
                        ValidateIssuerSigningKey = true,

                        // HS256 secret напрямую
                        IssuerSigningKey = new SymmetricSecurityKey(
                            System.Text.Encoding.UTF8.GetBytes(
                                Environment.GetEnvironmentVariable("SUPABASE_JWT_SECRET")
                            )
                        )
                    };
                });


            builder.Services.AddAuthorization();

            builder.Services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new OpenApiInfo
                {
                    Title = "My Supabase API",
                    Version = "v1",
                    Description = "API с авторизацией через Supabase"
                });

                // Настройка JWT через Bearer scheme
                c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
                {
                    Name = "Authorization",
                    Type = SecuritySchemeType.Http,
                    Scheme = "bearer",
                    BearerFormat = "JWT",
                    In = ParameterLocation.Header,
                    Description = "Введите JWT токен с префиксом 'Bearer '"
                });
                c.AddSecurityDefinition("RefreshToken", new OpenApiSecurityScheme
                {
                    Name = "X-Refresh-Token",
                    Type = SecuritySchemeType.ApiKey,
                    In = ParameterLocation.Header,
                    Description = "Введите refresh token"
                });
                c.AddSecurityRequirement(new OpenApiSecurityRequirement
                {
                    {
                        new OpenApiSecurityScheme
                        {
                            Reference = new OpenApiReference
                            {
                                Type = ReferenceType.SecurityScheme,
                                Id = "Bearer"
                            }
                        },
                        new List<string>() // пустой список scopes
                    },
                    {
                        new OpenApiSecurityScheme
                        {
                            Reference = new OpenApiReference
                            {
                                Type = ReferenceType.SecurityScheme,
                                Id = "RefreshToken"
                            }
                        },
                        new List<string>()
                    }
                });

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
            //app.UseMiddleware<SupabaseAuthMiddleware>();

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
            app.UseMiddleware<SupabaseAuthMiddleware>();
            app.UseAuthentication();
            app.UseAuthorization();




            app.MapControllers();

            app.Run();
        }
    }
}
