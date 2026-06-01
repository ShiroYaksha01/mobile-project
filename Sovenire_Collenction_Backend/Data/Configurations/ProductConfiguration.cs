namespace Sovenire_Collenction_Backend.Data.Configurations;

public class ProductConfiguration : IEntityTypeConfiguration<Product>
{
    public void Configure(EntityTypeBuilder<Product> builder)
    {
        builder.ToTable("products");

        builder.HasKey(p => p.Id);

        builder.Property(p => p.Title)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(p => p.Slug)
            .IsUnique()
            .HasMaxLength(220);

        builder.Property(p => p.Price)
            .HasColumnType("decimal(10,2)");

        builder.Property(p => p.SalePrice)
            .HasColumnType("decimal(10,2)");

        builder.HasOne(p => p.Category)
            .WithMany(c => c.Products)
            .HasForeignKey(p => p.CategoryId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(p => p.Artisan)
            .WithMany(a => a.Products)
            .HasForeignKey(p => p.ArtisanId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}