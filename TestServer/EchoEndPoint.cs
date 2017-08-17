using System.Threading.Tasks;
using Microsoft.AspNetCore.Sockets;

namespace TestServer
{
    public class EchoEndPoint : EndPoint
    {
        public async override Task OnConnectedAsync(ConnectionContext connectionContext)
        {
            while (true)
            {
                await connectionContext.Transport.Out.WriteAsync(
                    await connectionContext.Transport.In.ReadAsync());
            }
        }
    }
}
