using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;

namespace TestServer
{
    public class TestHub : Hub
    {
        public string Echo(string message)
        {
            return message;
        }
    }
}