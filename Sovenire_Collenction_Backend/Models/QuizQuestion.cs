namespace Souvenir_Collection_Backend.Models;

public class QuizQuestion
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    public string QuestionText { get; set; } = string.Empty;
    public int DisplayOrder { get; set; } = 0;

    public ICollection<QuizAnswer> QuizAnswers { get; set; }
}