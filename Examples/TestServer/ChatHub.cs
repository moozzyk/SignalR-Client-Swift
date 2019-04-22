using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;

namespace TestServer
{
    public class ChatHub : Hub
    {
        public Task Broadcast(string sender, string message)
        {
            return Clients.All.SendAsync("NewMessage", sender, message);
        }
    }
}