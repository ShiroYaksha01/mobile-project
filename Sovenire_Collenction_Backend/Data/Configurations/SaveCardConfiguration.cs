namespace Souvenir_Collection_Backend.Data.Configurations;

public class SavedCardConfiguration : IEntityTypeConfiguration<SavedCard>
{
    public void Configure(EntityTypeBuilder<SavedCard> builder)
    {
        builder.ToTable("saved_cards");
        builder.HasKey(sc => sc.Id);

        builder.Property(sc => sc.Gateway)
            .IsRequired()
            .HasMaxLength(20);

        builder.Property(sc => sc.GatewayCustomerId)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(sc => sc.GatewayPaymentMethodId)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(sc => sc.CardBrand)
            .HasMaxLength(20);

        builder.Property(sc => sc.Last4)
            .HasMaxLength(4);

        builder.Property(sc => sc.IsDefault)
            .HasDefaultValue(false);

        builder.HasOne(sc => sc.User)
            .WithMany(u => u.SavedCards)
            .HasForeignKey(sc => sc.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}