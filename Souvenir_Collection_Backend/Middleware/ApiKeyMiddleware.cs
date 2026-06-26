using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using System.Threading.Tasks;

namespace Sovenire_Collenction_Backend.Middleware
{
    public class ApiKeyMiddleware
    {
        private readonly RequestDelegate _next;

        public ApiKeyMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context, IConfiguration configuration)
        {
            // 1. Bypass verification for Swagger documentation, root path, and SignalR hubs
            var path = context.Request.Path.Value ?? "";
            // Also bypass OPTIONS (CORS preflight) requests
            if (path.StartsWith("/swagger") || path == "/" || path.Contains("/chatHub") || context.Request.Method == "OPTIONS")
            {
                await _next(context);
                return;
            }

            // 3. Extract and validate X-API-KEY header
            const string API_KEY_HEADER = "X-API-KEY";
            if (!context.Request.Headers.TryGetValue(API_KEY_HEADER, out var extractedApiKey))
            {
                context.Response.StatusCode = 401;
                context.Response.ContentType = "application/json";
                await context.Response.WriteAsJsonAsync(new { success = false, message = "API Key is missing." });
                return;
            }

            var apiKey = configuration["ApiKey"];
            if (string.IsNullOrEmpty(apiKey) || !apiKey.Equals(extractedApiKey))
            {
                context.Response.StatusCode = 401;
                context.Response.ContentType = "application/json";
                await context.Response.WriteAsJsonAsync(new { success = false, message = "Unauthorized client. Invalid API Key." });
                return;
            }

            await _next(context);
        }
    }
}