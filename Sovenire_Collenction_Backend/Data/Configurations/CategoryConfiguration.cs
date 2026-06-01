namespace Souvenir_Collection_Backend.Data.Configurations;

public class CategoryConfiguration : IEntityTypeConfiguration<Category>
{
    public void Configure(EntityTypeBuilder<Category> builder)
    {
        builder.ToTable("categories");
        builder.HasKey(c => c.Id);

        builder.Property(c => c.Name)
            .IsRequired()
            .HasMaxLength(80);

        builder.Property(c => c.Slug)
            .IsRequired()
            .HasMaxLength(80);

        builder.HasIndex(c => c.Slug)
            .IsUnique();

        builder.Property(c => c.DisplayOrder)
            .HasDefaultValue(0);

        builder.HasMany(c => c.Products)
            .WithOne(p => p.Category)
            .HasForeignKey(p => p.CategoryId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}