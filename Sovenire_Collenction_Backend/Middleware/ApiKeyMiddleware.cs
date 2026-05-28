namespace Sovenire_Collenction_Backend.Middleware
{
    public class ApiKeyMiddleware
    {
        private readonly RequestDelegate _next;
        public ApiKeyMiddleware(RequestDelegate next) => _next = next;
        public async Task InvokeAsync(HttpContext context) 
        {
            Console.WriteLine($" {context.Request.Method} {context.Request.Path}");
            await _next(context);
            Console.WriteLine($" Response: {context.Response.StatusCode}");
        }
        await _next(context);
    }
}