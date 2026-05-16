namespace MessengerServer.Services;

public interface IFileStorageService
{
    Task<string> SaveAsync(IFormFile file, CancellationToken ct = default);
}

public class LocalFileStorageService : IFileStorageService
{
    private readonly string _root;

    public LocalFileStorageService(IConfiguration cfg)
    {
        _root = cfg["Storage:FileRoot"] ?? "Storage";
        Directory.CreateDirectory(_root);
    }

    public async Task<string> SaveAsync(IFormFile file, CancellationToken ct = default)
    {
        var safeName = $"{Guid.NewGuid()}_{Path.GetFileName(file.FileName)}";
        var fullPath = Path.Combine(_root, safeName);

        await using var stream = File.Create(fullPath);
        await file.CopyToAsync(stream, ct);
        return $"/{_root}/{safeName}".Replace("\\", "/");
    }
}
