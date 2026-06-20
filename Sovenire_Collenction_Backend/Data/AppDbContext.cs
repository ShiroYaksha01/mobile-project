using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;
using Souvenir_Collection_Backend.Models;
using Souvenir_Collection_Backend.Enums;
using System.Text.RegularExpressions;

namespace Souvenir_Collection_Backend.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<User> Users { get; set; }
    public DbSet<Artisan> Artisans { get; set; }
    public DbSet<Category> Categories { get; set; }
    public DbSet<Product> Products { get; set; }
    public DbSet<Collection> Collections { get; set; }
    public DbSet<CartItem> CartItems { get; set; }
    public DbSet<Favorite> Favorites { get; set; }
    public DbSet<Order> Orders { get; set; }
    public DbSet<OrderItem> OrderItems { get; set; }
    public DbSet<Payment> Payments { get; set; }
    public DbSet<SavedCard> SavedCards { get; set; }
    public DbSet<Promotion> Promotions { get; set; }
    public DbSet<Review> Reviews { get; set; }
    public DbSet<ChatRoom> ChatRooms { get; set; }
    public DbSet<ChatMessage> ChatMessages { get; set; }
    public DbSet<QuizQuestion> QuizQuestions { get; set; }
    public DbSet<QuizAnswer> QuizAnswers { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Map to Supabase/PostgreSQL snake_case table names
        modelBuilder.Entity<User>().ToTable("users");
        modelBuilder.Entity<Artisan>().ToTable("artisans");
        modelBuilder.Entity<Category>().ToTable("categories");
        modelBuilder.Entity<Product>().ToTable("products");
        modelBuilder.Entity<Collection>().ToTable("collections");
        modelBuilder.Entity<CartItem>().ToTable("cart_items");
        modelBuilder.Entity<Favorite>().ToTable("favorites");
        modelBuilder.Entity<Order>().ToTable("orders");
        modelBuilder.Entity<OrderItem>().ToTable("order_items");
        modelBuilder.Entity<Payment>().ToTable("payments");
        modelBuilder.Entity<SavedCard>().ToTable("saved_cards");
        modelBuilder.Entity<Promotion>().ToTable("promotions");
        modelBuilder.Entity<Review>().ToTable("reviews");
        modelBuilder.Entity<ChatRoom>().ToTable("chat_rooms");
        modelBuilder.Entity<ChatMessage>().ToTable("chat_messages");
        modelBuilder.Entity<QuizQuestion>().ToTable("quiz_questions");
        modelBuilder.Entity<QuizAnswer>().ToTable("quiz_answers");
        modelBuilder.Entity<QuizAnswer>()
            .HasOne(a => a.QuizQuestion)
            .WithMany(q => q.QuizAnswers)
            .HasForeignKey(a => a.QuestionId);

        modelBuilder.Entity<ChatMessage>()
            .HasOne(m => m.ChatRoom)
            .WithMany(r => r.ChatMessages)
            .HasForeignKey(m => m.RoomId);

        modelBuilder.Entity<ChatRoom>()
            .HasOne(r => r.User)
            .WithMany()
            .HasForeignKey(r => r.UserId);

        modelBuilder.Entity<Artisan>()
            .HasOne(a => a.User)
            .WithMany()
            .HasForeignKey(a => a.UserId)
            .IsRequired(false);

        modelBuilder.Entity<ChatRoom>()
            .HasOne(r => r.Artisan)
            .WithMany()
            .HasForeignKey(r => r.ArtisanId);

        // Ignore all properties inherited from Supabase BaseModel for User entity
        // These are internal Supabase/Postgrest properties not mapped to DB columns
        var baseModelType = typeof(Supabase.Postgrest.Models.BaseModel);
        var userEntity = modelBuilder.Entity<User>();
        foreach (var prop in baseModelType.GetProperties())
        {
            userEntity.Ignore(prop.Name);
        }

        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);

        // -------------------------------------------------------
        // Global convention: map all PascalCase property names
        // to snake_case column names to match Supabase PostgreSQL schema
        // -------------------------------------------------------
        foreach (var entity in modelBuilder.Model.GetEntityTypes())
        {
            foreach (var property in entity.GetProperties())
            {
                // Only set the column name if it hasn't been explicitly configured
                var storeObjectId = StoreObjectIdentifier.Table(
                    entity.GetTableName()!, entity.GetSchema());
                var columnName = property.GetColumnName(storeObjectId);
                
                // If the column name equals the property name (default EF behavior),
                // convert it to snake_case
                if (columnName == property.Name)
                {
                    property.SetColumnName(ToSnakeCase(property.Name));
                }
            }

            // Also map FK shadow properties to snake_case
            foreach (var key in entity.GetForeignKeys())
            {
                foreach (var property in key.Properties)
                {
                    var storeObjectId = StoreObjectIdentifier.Table(
                        entity.GetTableName()!, entity.GetSchema());
                    var columnName = property.GetColumnName(storeObjectId);
                    if (columnName == property.Name)
                    {
                        property.SetColumnName(ToSnakeCase(property.Name));
                    }
                }
            }
        }
    }

    /// <summary>
    /// Converts PascalCase to snake_case.
    /// e.g. "ArtisanId" -> "artisan_id", "DisplayName" -> "display_name"
    /// </summary>
    private static string ToSnakeCase(string input)
    {
        if (string.IsNullOrEmpty(input)) return input;
        // Insert underscore before uppercase letters that follow lowercase/digit
        var result = Regex.Replace(input, "([a-z0-9])([A-Z])", "$1_$2");
        // Handle consecutive uppercase like "URL" -> keep together, "ProfilePhotoURL" -> "profile_photo_url"
        result = Regex.Replace(result, "([A-Z]+)([A-Z][a-z])", "$1_$2");
        return result.ToLower();
    }
}