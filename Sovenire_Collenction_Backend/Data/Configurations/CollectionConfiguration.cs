using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Souvenir_Collection_Backend.Models;

namespace Souvenir_Collection_Backend.Data.Configurations;

public class CollectionConfiguration : IEntityTypeConfiguration<Collection>
{
    public void Configure(EntityTypeBuilder<Collection> builder)
    {
        builder.ToTable("collections");

        builder.HasKey(c => c.Id);

        builder.Property(c => c.Title)
            .IsRequired()
            .HasMaxLength(150);

        builder.Property(c => c.Slug)
            .IsRequired()
            .HasMaxLength(150);

        builder.HasIndex(c => c.Slug)
            .IsUnique();

        builder.Property(c => c.Description)
            .HasColumnType("text");

        builder.Property(c => c.Type)
            .IsRequired()
            .HasMaxLength(20);

        builder.Property(c => c.DisplayOrder)
            .HasDefaultValue(0);

        builder.HasMany(c => c.CollectionProducts)
            .WithOne(cp => cp.Collection)
            .HasForeignKey(cp => cp.CollectionId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(c => c.Favorites)
            .WithOne(f => f.Collection)
            .HasForeignKey(f => f.CollectionId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}