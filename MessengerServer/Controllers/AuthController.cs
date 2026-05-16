using MessengerServer.Dtos;
using MessengerServer.Services;
using Microsoft.AspNetCore.Mvc;

namespace MessengerServer.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _auth;

    public AuthController(IAuthService auth)
    {
        _auth = auth;
    }

    [HttpPost("register")]
    public async Task<ActionResult<AuthResponse>> Register(RegisterRequest request)
    {
        try { return Ok(await _auth.RegisterAsync(request)); }
        catch (InvalidOperationException ex) { return Conflict(ex.Message); }
    }

    [HttpPost("login")]
    public async Task<ActionResult<AuthResponse>> Login(LoginRequest request)
    {
        try { return Ok(await _auth.LoginAsync(request)); }
        catch (UnauthorizedAccessException ex) { return Unauthorized(ex.Message); }
    }
}
