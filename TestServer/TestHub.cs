using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;

namespace TestServer
{
    public class TestHub : Hub
    {
        private ILogger _logger;

        public TestHub(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<TestHub>();
        }

        public string Echo(string message)
        {
            _logger.LogInformation("Echo invoked: " + message);
            return message;
        }
    }
}