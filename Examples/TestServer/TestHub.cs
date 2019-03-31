using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Threading.Channels;
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

        public void ErrorMethod()
        {
            throw new InvalidOperationException("Error occurred.");
        }

        public Task VoidMethod()
        {
            return Task.CompletedTask;
        }

        public Task InvokeGetNumber(int number)
        {
            return Clients.Client(Context.ConnectionId).SendAsync("GetNumber", number);
        }

        public Task InvokeGetPerson(Person person)
        {
            return Clients.Client(Context.ConnectionId).SendAsync("GetPerson", person);
        }

        public IEnumerable<Person> SortByName(Person[] people)
        {
            return people.OrderBy(p => p.LastName).ThenBy(p => p.FirstName);
        }

        public ChannelReader<int> StreamNumbers(int count, int delay)
        {
            var channel = Channel.CreateUnbounded<int>();

            Task.Run(async () =>
            {
                for (var i = 0; i < count; i++)
                {
                    await channel.Writer.WriteAsync(i);
                    await Task.Delay(delay);
                }

                channel.Writer.TryComplete();
            });

            return channel.Reader;
        }

        public ChannelReader<string> ErrorStreamMethod()
        {
            var channel = Channel.CreateUnbounded<string>();

            Task.Run(async () =>
            {
                await channel.Writer.WriteAsync("abc");
                await channel.Writer.WriteAsync(null);
                channel.Writer.TryComplete(new InvalidOperationException("Error occurred while streaming."));
            });

            return channel.Reader;
        }

        public string GetHeader(string name)
        {
            Context.GetHttpContext().Request.Headers.TryGetValue(name, out var header);
            return header;
        }
    }
}
