namespace Souvenir_Collection_Backend.Data.Configurations
{
    public class ChatRoomConfiguration : IEntityTypeConfiguration<ChatRoom>
    {
        public void Configure(EntityTypeBuilder<ChatRoom> builder)
        {
            builder.ToTable("chat_rooms");

            builder.HasKey(r => r.Id);

            builder.HasOne(r => r.User)
                .WithMany()
                .HasForeignKey(r => r.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.HasOne(r => r.Artisan)
                .WithMany()
                .HasForeignKey(r => r.ArtisanId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.HasIndex(r => new { r.UserId, r.ArtisanId })
                .IsUnique();

            builder.HasMany(r => r.ChatMessages)
            .WithOne(m => m.ChatRoom)
            .HasForeignKey(m => m.RoomId)
            .OnDelete(DeleteBehavior.Cascade);
        }
    }
}