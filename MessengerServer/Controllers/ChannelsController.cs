using System.Security.Claims;
using MessengerServer.Data;
using MessengerServer.Dtos;
using MessengerServer.Models;
using MessengerServer.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace MessengerServer.Controllers;

[ApiController]
[Authorize]
[Route("api/channels")]
public class ChannelsController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly IMessageCipherService _cipher;
    private readonly IFileStorageService _files;

    public ChannelsController(AppDbContext db, IMessageCipherService cipher, IFileStorageService files)
    {
        _db = db;
        _cipher = cipher;
        _files = files;
    }

    [HttpPost]
    public async Task<ActionResult<Channel>> Create(CreateChannelRequest request)
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var channel = new Channel { Name = request.Name, CreatedByUserId = userId };
        _db.Channels.Add(channel);
        _db.ChannelMembers.Add(new ChannelMember { ChannelId = channel.Id, UserId = userId });
        await _db.SaveChangesAsync();
        return Ok(channel);
    }

    [HttpPost("{channelId:guid}/join")]
    public async Task<ActionResult> Join(Guid channelId)
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var exists = await _db.ChannelMembers.AnyAsync(x => x.ChannelId == channelId && x.UserId == userId);
        if (!exists) _db.ChannelMembers.Add(new ChannelMember { ChannelId = channelId, UserId = userId });
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("message")]
    public async Task<ActionResult> SendMessage(SendMessageRequest request)
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var isMember = await _db.ChannelMembers.AnyAsync(x => x.ChannelId == request.ChannelId && x.UserId == userId);
        if (!isMember) return Forbid();

        var message = new Message
        {
            ChannelId = request.ChannelId,
            SenderUserId = userId,
            CipherText = _cipher.Encrypt(request.Text)
        };

        _db.Messages.Add(message);
        await _db.SaveChangesAsync();
        return Ok(message.Id);
    }

    [HttpGet("{channelId:guid}/messages")]
    public async Task<ActionResult<List<MessageDto>>> GetMessages(Guid channelId)
    {
        var messages = await _db.Messages
            .Where(m => m.ChannelId == channelId)
            .OrderBy(m => m.SentAtUtc)
            .ToListAsync();

        var users = await _db.Users.ToDictionaryAsync(x => x.Id, x => x.UserName);

        return Ok(messages.Select(m => new MessageDto(
            m.Id,
            m.ChannelId,
            users.GetValueOrDefault(m.SenderUserId, "unknown"),
            _cipher.Decrypt(m.CipherText),
            m.FileUrl,
            m.SentAtUtc)).ToList());
    }

    [HttpPost("{channelId:guid}/files")]
    [RequestSizeLimit(1024L * 1024L * 200L)]
    public async Task<ActionResult> Upload(Guid channelId, IFormFile file, CancellationToken ct)
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var isMember = await _db.ChannelMembers.AnyAsync(x => x.ChannelId == channelId && x.UserId == userId, ct);
        if (!isMember) return Forbid();

        var url = await _files.SaveAsync(file, ct);
        var message = new Message
        {
            ChannelId = channelId,
            SenderUserId = userId,
            CipherText = _cipher.Encrypt($"[file] {file.FileName}"),
            FileUrl = url
        };
        _db.Messages.Add(message);
        await _db.SaveChangesAsync(ct);
        return Ok(new { url, messageId = message.Id });
    }
}
