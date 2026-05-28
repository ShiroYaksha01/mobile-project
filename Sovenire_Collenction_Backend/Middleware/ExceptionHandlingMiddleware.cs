namespace Sovenire_Collenction_Backend.Middleware
{
    public class ExceptionHandlingMiddleware
    {
        private readonly RequestDelegate _next;
        public ExceptionHandlingMiddleware(RequestDelegate next) => _next = next;
        public async Task InvokeAsync(HttpContext context) {
            try{
                await _next(context);
            }
            catch (Exception ex){
                Console.WriteLine($"Error: {ex.Message}");    
                context.Response.StatusCode = 500;
                await context.Response.WriteAsJsonAsync(new { error = ex.Message });    
            }
        } 
    }
}