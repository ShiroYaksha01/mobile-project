namespace Souvenir_Collection_Backend.Data.Configurations
{
    public class CollectionProductConfiguration : IEntityTypeConfiguration<CollectionProduct>
    {
        public void Configure(EntityTypeBuilder<CollectionProduct> builder)
        {
            builder.ToTable("collection_products");

            builder.HasIndex(cp => new { cp.CollectionId, cp.ProductId })
                .IsUnique();
        }
    }
}