using System.Threading.Channels;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;

namespace TestServer
{
    public class ChatHub : Hub
    {
        public Task Broadcast(string sender, string message)
        {
            if (message == "abort")
            {
                Context.Abort();
                return Task.CompletedTask;
            }

            return Clients.All.SendAsync("NewMessage", sender, message);
        }

        public async Task StreamingMax(string user, ChannelReader<int> stream)
        {
            int runningMax = int.MinValue;
            while (await stream.WaitToReadAsync())
            {
                while (stream.TryRead(out var n))
                {
                    if (n > runningMax)
                    {
                        runningMax = n;
                        await Clients.All.SendAsync("NewMessage", user, $"New max: {n}");
                    }
                }
            }
            await Clients.All.SendAsync("NewMessage", user, $"Ended with max of: {runningMax}");
        }
    }
}