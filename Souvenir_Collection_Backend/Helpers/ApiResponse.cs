namespace Sovenire_Collenction_Backend.Helpers
{
    public class ApiResponse<T>
    {
        public bool Success { get; set; } = true;
        public string Message { get; set; } = string.Empty;
        public T? Data { get; set; }

        public static ApiResponse<T> SuccessResult(T data, string message = "") => new() { Success = true, Data = data, Message = message };
        public static ApiResponse<T> FailureResult(string message) => new() { Success = false, Message = message };
    }
}
