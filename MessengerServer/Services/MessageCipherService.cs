using Microsoft.AspNetCore.DataProtection;

namespace MessengerServer.Services;

public interface IMessageCipherService
{
    string Encrypt(string plainText);
    string Decrypt(string cipherText);
}

public class MessageCipherService : IMessageCipherService
{
    private readonly IDataProtector _protector;

    public MessageCipherService(IDataProtectionProvider provider)
    {
        _protector = provider.CreateProtector("MessengerServer.Messages.v1");
    }

    public string Encrypt(string plainText) => _protector.Protect(plainText);

    public string Decrypt(string cipherText) => _protector.Unprotect(cipherText);
}
