using System.ComponentModel.DataAnnotations;

namespace Sovenire_Collenction_Backend.DTOs.Category
{
    public class CreateCategoryRequest
    {
        [Required(ErrorMessage = "Category name is required.")]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Category name must be between 2 and 50 characters.")]
        public string Name { get; set; } = string.Empty;

        public string? Image { get; set; }
    }
}
