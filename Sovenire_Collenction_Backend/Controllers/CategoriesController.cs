using Microsoft.AspNetCore.Mvc;
using Sovenire_Collenction_Backend.Helpers;
using Sovenire_Collenction_Backend.DTOs.Category;

namespace Sovenire_Collenction_Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CategoriesController : ControllerBase
    {
        private readonly CategoryService _categoryService;

        public CategoriesController(CategoryService categoryService)
        {
            _categoryService = categoryService;
        }

        // GET api/categories
        [HttpGet]
        public async Task<IActionResult> GetAllCategories()
        {
            var categories = await _categoryService.GetAllCategoriesAsync();
            var dtos = categories.Select(c => new CategoryDto
            {
                Id = c.Id,
                Name = c.Name,
                Image = c.Image,
                CreatedAt = c.CreatedAt,
                UpdatedAt = c.UpdatedAt
            }).ToList();

            var message = dtos.Any() ? "Categories retrieved successfully." : "No categories found.";
            return Ok(ApiResponse<List<CategoryDto>>.SuccessResult(dtos, message));
        }

        // GET api/categories/{id}
        [HttpGet("{id}")]
        public async Task<IActionResult> GetCategoryById(Guid id)
        {
            var category = await _categoryService.GetCategoryByIdAsync(id);
            if (category == null)
                return NotFound(ApiResponse<CategoryDto>.FailureResult($"Category with ID {id} not found."));

            var dto = new CategoryDto
            {
                Id = category.Id,
                Name = category.Name,
                Image = category.Image,
                CreatedAt = category.CreatedAt,
                UpdatedAt = category.UpdatedAt
            };

            return Ok(ApiResponse<CategoryDto>.SuccessResult(dto, "Category retrieved successfully."));
        }

        // POST api/categories
        [HttpPost]
        public async Task<IActionResult> CreateCategory([FromBody] CreateCategoryRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Name))
                return BadRequest(ApiResponse<CategoryDto>.FailureResult("Category name is required."));

            var category = await _categoryService.CreateCategoryAsync(request.Name, request.Image ?? "");

            var dto = new CategoryDto
            {
                Id = category.Id,
                Name = category.Name,
                Image = category.Image,
                CreatedAt = category.CreatedAt,
                UpdatedAt = category.UpdatedAt
            };

            return CreatedAtAction(nameof(GetCategoryById), new { id = category.Id },
                ApiResponse<CategoryDto>.SuccessResult(dto, "Category created successfully."));
        }

        // PUT api/categories/{id}
        [HttpPut("{id}")]
        [HttpPatch("{id}")]
        public async Task<IActionResult> UpdateCategory(Guid id, [FromBody] CreateCategoryRequest request)
        {
            var category = await _categoryService.UpdateCategoryAsync(id, request.Name, request.Image ?? "");
            if (category == null)
                return NotFound(ApiResponse<CategoryDto>.FailureResult($"Category with ID {id} not found."));

            var dto = new CategoryDto
            {
                Id = category.Id,
                Name = category.Name,
                Image = category.Image,
                CreatedAt = category.CreatedAt,
                UpdatedAt = category.UpdatedAt
            };

            return Ok(ApiResponse<CategoryDto>.SuccessResult(dto, "Category updated successfully."));
        }

        // DELETE api/categories/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteCategory(Guid id)
        {
            var success = await _categoryService.DeleteCategoryAsync(id);
            if (!success)
                return NotFound(ApiResponse<object>.FailureResult($"Category with ID {id} not found."));

            return Ok(ApiResponse<object>.SuccessResult(new { id = id }, "Category deleted successfully."));
        }
    }
}
