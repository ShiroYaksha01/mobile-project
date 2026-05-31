using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
// using Sovenire_Collenction_Backend.Hubs;
using Sovenire_Collenction_Backend.Middleware;
using Sovenire_Collenction_Backend.Services;
using Supabase;
using System.Text;

// Load environment variables from .env file for local development
DotNetEnv.Env.Load();

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddSingleton(provider => 
{

    try{

        var url = Environment.GetEnvironmentVariable("SUPABASE_URL")!;
        var key = Environment.GetEnvironmentVariable("SUPABASE_KEY")!;
   
        var client = new Supabase.Client(url, key, new SupabaseOptions
        {
            AutoRefreshToken = true
        });

        client.InitializeAsync().Wait();
    Console.WriteLine("Connected to Supabase!");
    return client;

    }catch(Exception ex){
        Console.WriteLine("Connection Failed: " + ex.Message);
        throw;
    }
});

// JWT
var jwtKey = builder.Configuration["JwtSettings:SecretKey"]!;
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(opt => opt.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer           = true,
        ValidateAudience         = true,
        ValidateLifetime         = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer              = builder.Configuration["JwtSettings:Issuer"],
        ValidAudience            = builder.Configuration["JwtSettings:Audience"],
        IssuerSigningKey         = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
        ClockSkew                = TimeSpan.Zero
    });
builder.Services.AddAuthorization();

// CORS for Flutter
builder.Services.AddCors(o => o.AddPolicy("Flutter", p =>
    p.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader()));

// DbContext setup removed as we now use Supabase Client SDK directly over HTTPS.

// Services
// builder.Services.AddAutoMapper(typeof(Program));
builder.Services.AddHttpClient(); // needed by AuthService for Google token verification
builder.Services.AddControllers();
// builder.Services.AddSignalR();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddScoped<TokenService>();
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<UserService>();
/*
builder.Services.AddScoped<ProductService>();
builder.Services.AddScoped<ArtisanService>();
builder.Services.AddScoped<CollectionService>();
builder.Services.AddScoped<OrderService>();
builder.Services.AddScoped<ReviewService>();
builder.Services.AddScoped<PromotionService>();
builder.Services.AddScoped<ShopService>();
builder.Services.AddScoped<ChatService>();
builder.Services.AddScoped<FavoriteService>();
builder.Services.AddScoped<CartService>();
builder.Services.AddScoped<QuizService>();
builder.Services.AddScoped<MediaService>();
builder.Services.AddScoped<AdminService>();
*/

var app = builder.Build();

app.Services.GetRequiredService<Supabase.Client>();
app.UseMiddleware<ExceptionHandlingMiddleware>();
app.UseMiddleware<RequestLoggingMiddleware>();
app.UseMiddleware<ApiKeyMiddleware>();
app.UseSwagger();
app.UseSwaggerUI();
app.UseCors("Flutter");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
// app.MapHub<ChatHub>("/hubs/chat");

app.Run();
