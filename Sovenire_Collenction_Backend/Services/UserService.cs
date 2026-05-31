using Supabase;
using Souvenir_Collection_Backend.Models;
using static Supabase.Postgrest.Constants;

namespace Souvenir_Collection_Backend.Services;

public class UserService
{
    private readonly Client _supabase;

    public UserService(Client supabase)
    {
        _supabase = supabase;
    }

    public async Task<List<User>> GetAllUsersAsync()
    {
        var result = await _supabase.From<User>()
            .Order("created_at", Ordering.Descending)
            .Get();
        return result.Models;
    }

    public async Task<User?> GetUserByIdAsync(Guid id)
    {
        var result = await _supabase.From<User>()
            .Where(u => u.Id == id)
            .Get();
        return result.Model;
    }

    public async Task<User?> GetUserByEmailAsync(string email)
    {
        var result = await _supabase.From<User>()
            .Where(u => u.Email == email)
            .Get();
        return result.Model;
    }

    public async Task<User?> GetUserByPhoneAsync(string phone)
    {
        var result = await _supabase.From<User>()
            .Where(u => u.Phone == phone)
            .Get();
        return result.Model;
    }

    public async Task<User> CreateUserAsync(User user)
    {
        var result = await _supabase.From<User>().Insert(user);
        return result.Model ?? user;
    }

    public async Task<User?> UpdateUserAsync(Guid id, User updated)
    {
        var result = await _supabase.From<User>().Where(u => u.Id == id).Get();
        var user = result.Model;
        if (user == null) return null;

        user.Name = updated.Name;
        user.Email = updated.Email;
        user.Phone = updated.Phone;
        user.Address = updated.Address;
        user.Avatar = updated.Avatar;
        user.Role = updated.Role;
        user.UpdatedAt = DateTime.UtcNow;

        var updateResult = await _supabase.From<User>().Update(user);
        return updateResult.Model;
    }

    public async Task<bool> DeleteUserAsync(Guid id)
    {
        await _supabase.From<User>().Where(u => u.Id == id).Delete();
        return true;
    }

    public async Task<bool> EmailExistsAsync(string email)
    {
        var result = await _supabase.From<User>().Where(u => u.Email == email).Get();
        return result.Models.Any();
    }

    public async Task<bool> PhoneExistsAsync(string phone)
    {
        var result = await _supabase.From<User>().Where(u => u.Phone == phone).Get();
        return result.Models.Any();
    }

    public async Task<bool> UpdatePasswordAsync(Guid id, string newPasswordHash)
    {
        var result = await _supabase.From<User>().Where(u => u.Id == id).Get();
        var user = result.Model;
        if (user == null) return false;

        user.PasswordHash = newPasswordHash;
        user.UpdatedAt = DateTime.UtcNow;

        await _supabase.From<User>().Update(user);
        return true;
    }

    public async Task<bool> UpdateAvatarAsync(Guid id, string avatarUrl)
    {
        var result = await _supabase.From<User>().Where(u => u.Id == id).Get();
        var user = result.Model;
        if (user == null) return false;

        user.Avatar = avatarUrl;
        user.UpdatedAt = DateTime.UtcNow;

        await _supabase.From<User>().Update(user);
        return true;
    }

    public async Task<List<User>> GetUsersByRoleAsync(UserRole role)
    {
        var result = await _supabase.From<User>()
            .Where(u => u.Role == role)
            .Order("created_at", Ordering.Descending)
            .Get();
        return result.Models;
    }
}