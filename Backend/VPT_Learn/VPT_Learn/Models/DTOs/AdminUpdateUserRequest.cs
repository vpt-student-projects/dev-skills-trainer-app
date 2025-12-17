public class AdminUpdateUserRequest
{
    public Guid UserUuid { get; set; }
    public string? NewEmail { get; set; }
    public string? NewPassword { get; set; }
}
