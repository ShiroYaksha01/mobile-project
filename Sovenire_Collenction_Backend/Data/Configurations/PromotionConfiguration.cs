using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Souvenir_Collection_Backend.Models;
using Souvenir_Collection_Backend.Enums;

namespace Souvenir_Collection_Backend.Data.Configurations;

public class PromotionConfiguration : IEntityTypeConfiguration<Promotion>
{
    public void Configure(EntityTypeBuilder<Promotion> builder)
    {
        builder.ToTable("promotions");

        builder.HasKey(p => p.Id);

        builder.Property(p => p.Code)
            .IsRequired()
            .HasMaxLength(30);

        builder.HasIndex(p => p.Code)
            .IsUnique();

        builder.Property(p => p.Title)
            .IsRequired()
            .HasMaxLength(150);

        builder.Property(p => p.DiscountType)
            .HasConversion<string>();

        builder.Property(p => p.DiscountValue)
            .HasColumnType("decimal(10,2)");

        builder.Property(p => p.Occasion)
            .HasMaxLength(60);

        builder.Property(p => p.MaxUses)
            .HasDefaultValue(0);

        builder.Property(p => p.TimesUsed)
            .HasDefaultValue(0);

        builder.HasMany(p => p.Orders)
            .WithOne(o => o.Promotion)
            .HasForeignKey(o => o.PromotionId)
            .OnDelete(DeleteBehavior.SetNull);
    }
}