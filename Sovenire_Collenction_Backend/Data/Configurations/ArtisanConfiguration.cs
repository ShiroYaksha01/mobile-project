
namespace Souvenir_Collection_Backend.Data.Configurations;

public class ArtisanConfiguration : IEntityTypeConfiguration<Artisan>
{
    public void Configure(EntityTypeBuilder<Artisan> builder)
    {
        builder.ToTable("artisans");

        builder.HasKey(a => a.Id);

        builder.Property(a => a.DisplayName)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(a => a.Lat)
            .HasColumnType("decimal(9,6)");

        builder.Property(a => a.Lng)
            .HasColumnType("decimal(9,6)");

        builder.HasOne(a => a.User)
            .WithOne()
            .HasForeignKey<Artisan>(a => a.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(a => a.Products)
            .WithOne(p => p.Artisan)
            .HasForeignKey(p => p.ArtisanId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}