using System.Threading.Tasks;
using Microsoft.AspNetCore.Sockets;

namespace TestServer
{
    public class EchoEndPoint : EndPoint
    {
        public async override Task OnConnectedAsync(Connection connection)
        {
            while (true)
            {
                await connection.Transport.Output.WriteAsync(await connection.Transport.Input.ReadAsync());
            }
        }
    }
}
