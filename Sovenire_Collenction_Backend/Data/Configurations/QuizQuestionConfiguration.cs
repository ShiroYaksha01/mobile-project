namespace Souvenir_Collection_Backend.Data.Configurations;

public class QuizQuestionConfiguration : IEntityTypeConfiguration<QuizQuestion>
{
    public void Configure(EntityTypeBuilder<QuizQuestion> builder)
    {
        builder.ToTable("quiz_questions");
        builder.HasKey(q => q.Id);

        builder.Property(q => q.QuestionText)
            .IsRequired()
            .HasColumnType("text");

        builder.Property(q => q.DisplayOrder)
            .HasDefaultValue(0);

        builder.HasMany(q => q.QuizAnswers)
            .WithOne(a => a.QuizQuestion)
            .HasForeignKey(a => a.QuestionId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}