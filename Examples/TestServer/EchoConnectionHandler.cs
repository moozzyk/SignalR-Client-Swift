using System.Buffers;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Connections;

namespace TestServer
{
    public class EchoConnectionHandler : ConnectionHandler
    {
        public async override Task OnConnectedAsync(ConnectionContext connection)
        {
            while (true)
            {
                var result = await connection.Transport.Input.ReadAsync();
                var buffer = result.Buffer;

                if (!buffer.IsEmpty)
                {
                    await connection.Transport.Output.WriteAsync(buffer.ToArray());
                }
                else if (result.IsCompleted)
                {
                    break;
                }

                connection.Transport.Input.AdvanceTo(buffer.End);
            }
        }
    }
}
