using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Sovenire_Collenction_Backend.Middleware;
using Sovenire_Collenction_Backend.Services;
using Supabase;
using System.Text;
using Npgsql;
using Souvenir_Collection_Backend.Enums;
using System.Text.Json.Serialization.Metadata;
using Microsoft.EntityFrameworkCore;
using Souvenir_Collection_Backend.Data;
using Sovenire_Collenction_Backend.Hubs;

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

    // Ensure "media" storage bucket exists
    try
    {
        client.Storage.CreateBucket("media", new Supabase.Storage.BucketUpsertOptions { Public = true });
        Console.WriteLine("Storage bucket 'media' created successfully.");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Note: Could not create 'media' bucket (may already exist): {ex.Message}");
    }

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

var dbPassword = Environment.GetEnvironmentVariable("DB_PASSWORD")
    ?? throw new InvalidOperationException("DB_PASSWORD environment variable is not set. Add it to your .env file.");
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") + $";Password={dbPassword}";
var maskedCs = System.Text.RegularExpressions.Regex.Replace(connectionString, @"Password=[^;]+", "Password=***");
Console.WriteLine($"[DEBUG] EF Core connection string: {maskedCs}");
Console.WriteLine($"[DEBUG] DB_PASSWORD length: {dbPassword.Length}, first 3 chars: {dbPassword[..Math.Min(3, dbPassword.Length)]}");
var translator = new Npgsql.NameTranslation.NpgsqlNullNameTranslator();
var dataSourceBuilder = new NpgsqlDataSourceBuilder(connectionString);
dataSourceBuilder.MapEnum<UserRole>("user_role", translator);
dataSourceBuilder.MapEnum<OrderStatus>("order_status", translator);
dataSourceBuilder.MapEnum<PaymentStatus>("payment_status", translator);
dataSourceBuilder.MapEnum<DiscountType>("discount_type", translator);
dataSourceBuilder.MapEnum<PromotionStatus>("promotion_status", translator);
var dataSource = dataSourceBuilder.Build();

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(dataSource, npgsqlOptions =>
    {
        npgsqlOptions.MapEnum<UserRole>("user_role", nameTranslator: translator);
        npgsqlOptions.MapEnum<OrderStatus>("order_status", nameTranslator: translator);
        npgsqlOptions.MapEnum<PaymentStatus>("payment_status", nameTranslator: translator);
        npgsqlOptions.MapEnum<DiscountType>("discount_type", nameTranslator: translator);
        npgsqlOptions.MapEnum<PromotionStatus>("promotion_status", nameTranslator: translator);
    })
    );

// Services
builder.Services.AddHttpClient(); // needed by AuthService for Google token verification
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.Converters.Add(new System.Text.Json.Serialization.JsonStringEnumConverter());
        var baseModelProperties = typeof(Supabase.Postgrest.Models.BaseModel).GetProperties().Select(p => p.Name.ToLowerInvariant()).ToHashSet();
        options.JsonSerializerOptions.TypeInfoResolver = new DefaultJsonTypeInfoResolver
        {
            Modifiers =
            {
                typeInfo =>
                {
                    if (typeof(Supabase.Postgrest.Models.BaseModel).IsAssignableFrom(typeInfo.Type))
                    {
                        for (int i = typeInfo.Properties.Count - 1; i >= 0; i--)
                        {
                            var propName = typeInfo.Properties[i].Name;
                            if (baseModelProperties.Contains(propName.ToLowerInvariant()))
                            {
                                typeInfo.Properties.RemoveAt(i);
                            }
                        }
                    }
                }
            }
        };
    });
builder.Services.AddSignalR();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("ApiKey", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
    {
        Name = "X-API-KEY",
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.ApiKey,
        In = Microsoft.OpenApi.Models.ParameterLocation.Header,
        Description = "API Key for the application"
    });
    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
    {
        {
            new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                Reference = new Microsoft.OpenApi.Models.OpenApiReference
                {
                    Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                    Id = "ApiKey"
                }
            },
            new List<string>()
        }
    });
});
builder.Services.AddScoped<TokenService>();
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<UserService>();
builder.Services.AddScoped<ArtisanService>();
builder.Services.AddScoped<ProductService>();
builder.Services.AddScoped<CategoryService>();
builder.Services.AddScoped<CollectionService>();
builder.Services.AddScoped<OrderService>();
builder.Services.AddScoped<ReviewService>();
builder.Services.AddScoped<PromotionService>();
builder.Services.AddScoped<ChatService>();
builder.Services.AddScoped<FavoriteService>();
builder.Services.AddScoped<CartService>();
builder.Services.AddScoped<QuizService>();
builder.Services.AddScoped<Souvenir_Collection_Backend.Services.UserCollectionService>();

var app = builder.Build();

app.Services.GetRequiredService<Supabase.Client>();

// Alter database tables/schema on startup
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    try
    {
        await context.Database.ExecuteSqlRawAsync("ALTER TABLE chat_messages DROP CONSTRAINT IF EXISTS chat_messages_sender_id_fkey;");
        await context.Database.ExecuteSqlRawAsync("ALTER TABLE artisans ADD COLUMN IF NOT EXISTS user_id uuid;");
        await context.Database.ExecuteSqlRawAsync("ALTER TABLE products ADD COLUMN IF NOT EXISTS collection_id uuid REFERENCES collections(id);");
        await context.Database.ExecuteSqlRawAsync("ALTER TABLE products DROP COLUMN IF EXISTS collection_display_order CASCADE;");
        await context.Database.ExecuteSqlRawAsync("ALTER TABLE collections DROP COLUMN IF EXISTS display_order CASCADE;");
        await context.Database.ExecuteSqlRawAsync(@"
            CREATE TABLE IF NOT EXISTS user_collections (
                id uuid PRIMARY KEY,
                user_id uuid REFERENCES users(id),
                name character varying(150) NOT NULL,
                created_at timestamp with time zone NOT NULL
            );
            CREATE TABLE IF NOT EXISTS user_collection_items (
                id uuid PRIMARY KEY,
                user_collection_id uuid REFERENCES user_collections(id) ON DELETE CASCADE,
                product_id uuid REFERENCES products(id),
                quantity integer NOT NULL DEFAULT 1
            );
        ");
        Console.WriteLine("Database schema altered successfully (user_id and collection_id verified, constraints and display_orders adjusted, user collections created).");

        using (var command = context.Database.GetDbConnection().CreateCommand())
        {
            command.CommandText = "SELECT typname FROM pg_type WHERE typcategory = 'E';";
            await context.Database.OpenConnectionAsync();
            using (var reader = await command.ExecuteReaderAsync())
            {
                var types = new List<string>();
                while (await reader.ReadAsync())
                {
                    types.Add(reader.GetString(0));
                }
                Console.WriteLine("[DEBUG DB] Enum types in DB: " + string.Join(", ", types));
            }
        }
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error altering schema: {ex.Message}");
    }
}

app.UseMiddleware<ExceptionHandlingMiddleware>();
app.UseMiddleware<ApiKeyMiddleware>();
app.UseSwagger();
app.UseSwaggerUI();
app.UseCors("Flutter");

app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.MapHub<ChatHub>("/chatHub");

app.Run();
