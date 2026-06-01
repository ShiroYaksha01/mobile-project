namespace Souvenir_Collection_Backend.Data.Configurations;

public class QuizAnswerConfiguration : IEntityTypeConfiguration<QuizAnswer>
{
    public void Configure(EntityTypeBuilder<QuizAnswer> builder)
    {
        builder.ToTable("quiz_answers");
        builder.HasKey(a => a.Id);

        builder.Property(a => a.AnswerText)
            .IsRequired()
            .HasMaxLength(255);

        builder.Property(a => a.IsCorrect)
            .IsRequired();

        builder.HasOne(a => a.Question)
            .WithMany(q => q.QuizAnswers)
            .HasForeignKey(a => a.QuestionId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}