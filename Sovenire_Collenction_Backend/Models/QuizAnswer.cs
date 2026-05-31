namespace Souvenir_Collection_Backend.Models;

public class QuizAnswer
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid QuestionId { get; set; }
    public QuizQuestion QuizQuestion { get; set; }

    public string AnswerText { get; set; } = string.Empty;
    public string Tags { get; set; } = string.Empty; 
}