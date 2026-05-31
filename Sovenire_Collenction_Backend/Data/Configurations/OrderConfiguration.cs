namespace Souvenir_Collection_Backend.Data.Configurations
{
    public class OrderConfiguration : IEntityTypeConfiguration<Order>
{
    public void Configure(EntityTypeBuilder<Order> builder)
    {
        builder.ToTable("orders");

        builder.HasKey(o => o.Id);

        builder.Property(o => o.Status)
            .HasConversion<string>();

        builder.Property(o => o.TotalAmount)
            .HasColumnType("decimal(10,2)");

        builder.Property(o => o.DiscountAmount)
            .HasColumnType("decimal(10,2)")
            .HasDefaultValue(0);

        builder.HasOne(o => o.User)
            .WithMany(u => u.Orders)
            .HasForeignKey(o => o.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasMany(o => o.OrderItems)
            .WithOne(oi => oi.Order)
            .HasForeignKey(oi => oi.OrderId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
}