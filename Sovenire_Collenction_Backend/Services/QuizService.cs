using Microsoft.EntityFrameworkCore;
using Souvenir_Collection_Backend.Models;

namespace Souvenir_Collection_Backend.Services;

public class QuizService
{
    private readonly ApplicationDbContext _context;

    public QuizService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<QuizQuestion>> GetAllQuestionsAsync()
    {
        return await _context.QuizQuestions
            .Include(q => q.QuizAnswers)
            .OrderBy(q => q.DisplayOrder)
            .ToListAsync();
    }

    public async Task<QuizQuestion?> GetQuestionByIdAsync(Guid id)
    {
        return await _context.QuizQuestions
            .Include(q => q.QuizAnswers)
            .FirstOrDefaultAsync(q => q.Id == id);
    }

    public async Task<QuizQuestion> CreateQuestionAsync(QuizQuestion question)
    {
        _context.QuizQuestions.Add(question);
        await _context.SaveChangesAsync();
        return question;
    }

    public async Task<QuizQuestion?> UpdateQuestionAsync(Guid id, QuizQuestion updated)
    {
        var question = await _context.QuizQuestions.FindAsync(id);
        if (question == null) return null;

        question.QuestionText = updated.QuestionText;
        question.DisplayOrder = updated.DisplayOrder;

        await _context.SaveChangesAsync();
        return question;
    }

    public async Task<bool> DeleteQuestionAsync(Guid id)
    {
        var question = await _context.QuizQuestions.FindAsync(id);
        if (question == null) return false;

        _context.QuizQuestions.Remove(question);
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<List<QuizAnswer>> GetAnswersByQuestionIdAsync(Guid questionId)
    {
        return await _context.QuizAnswers
            .Where(a => a.QuestionId == questionId)
            .ToListAsync();
    }

    public async Task<QuizAnswer> CreateAnswerAsync(QuizAnswer answer)
    {
        _context.QuizAnswers.Add(answer);
        await _context.SaveChangesAsync();
        return answer;
    }

    public async Task<QuizAnswer?> UpdateAnswerAsync(Guid id, QuizAnswer updated)
    {
        var answer = await _context.QuizAnswers.FindAsync(id);
        if (answer == null) return null;

        answer.AnswerText = updated.AnswerText;
        answer.Tags = updated.Tags;

        await _context.SaveChangesAsync();
        return answer;
    }

    public async Task<bool> DeleteAnswerAsync(Guid id)
    {
        var answer = await _context.QuizAnswers.FindAsync(id);
        if (answer == null) return false;

        _context.QuizAnswers.Remove(answer);
        await _context.SaveChangesAsync();
        return true;
    }
}