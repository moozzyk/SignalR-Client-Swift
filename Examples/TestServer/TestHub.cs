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

        public void KillConnection()
        {
            Context.Abort();
        }

        public Task InvokeManyArgs(object[] args)
        {
            return Clients.Client(Context.ConnectionId).SendCoreAsync("ManyArgs", args);
        }

        public async Task<bool> InvokeNoArgs()
        {
            await Clients.Client(Context.ConnectionId).SendAsync("ManyArgs");
            return true;
        }

        public async Task<bool> InvokeManyArgs1(object arg1)
        {
            await Clients.Client(Context.ConnectionId).SendAsync("ManyArgs", arg1);
            return true;
        }

        public async Task<bool> InvokeManyArgs2(object arg1, object arg2)
        {
            await Clients.Client(Context.ConnectionId).SendAsync("ManyArgs", arg1, arg2);
            return true;
        }

        public async Task<bool> InvokeManyArgs3(object arg1, object arg2, object arg3)
        {
            await Clients.Client(Context.ConnectionId).SendAsync("ManyArgs", arg1, arg2, arg3);
            return true;
        }

        public async Task<bool> InvokeManyArgs4(object arg1, object arg2, object arg3, object arg4)
        {
            await Clients.Client(Context.ConnectionId).SendAsync("ManyArgs", arg1, arg2, arg3, arg4);
            return true;
        }

        public async Task<bool> InvokeManyArgs5(object arg1, object arg2, object arg3, object arg4, object arg5)
        {
            await Clients.Client(Context.ConnectionId).SendAsync("ManyArgs", arg1, arg2, arg3, arg4, arg5);
            return true;
        }

        public async Task<bool> InvokeManyArgs6(object arg1, object arg2, object arg3, object arg4, object arg5, object arg6)
        {
            await Clients.Client(Context.ConnectionId).SendAsync("ManyArgs", arg1, arg2, arg3, arg4, arg5, arg6);
            return true;
        }

        public async Task<bool> InvokeManyArgs7(object arg1, object arg2, object arg3, object arg4, object arg5, object arg6, object arg7)
        {
            await Clients.Client(Context.ConnectionId).SendAsync("ManyArgs", arg1, arg2, arg3, arg4, arg5, arg6, arg7);
            return true;
        }

        public async Task<bool> InvokeManyArgs8(object arg1, object arg2, object arg3, object arg4, object arg5, object arg6, object arg7, object arg8)
        {
            await Clients.Client(Context.ConnectionId).SendAsync("ManyArgs", arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
            return true;
        }

        public string Concatenate(string s, int n)
        {
            return $"{s} {n}";
        }

        public ChannelReader<object> StreamManyArgs0()
        {
            return StreamManyArgs(new object[] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 });
        }

        public ChannelReader<object> StreamManyArgs1(object n1)
        {
            return StreamManyArgs(new[] { n1 });
        }

        public ChannelReader<object> StreamManyArgs2(object n1, object n2)
        {
            return StreamManyArgs(new[] { n1, n2 });
        }

        public ChannelReader<object> StreamManyArgs3(object n1, object n2, object n3)
        {
            return StreamManyArgs(new[] { n1, n2, n3 });
        }

        public ChannelReader<object> StreamManyArgs4(object n1, object n2, object n3, object n4)
        {
            return StreamManyArgs(new[] { n1, n2, n3, n4 });
        }

        public ChannelReader<object> StreamManyArgs5(object n1, object n2, object n3, object n4, object n5)
        {
            return StreamManyArgs(new[] { n1, n2, n3, n4, n5 });
        }
        public ChannelReader<object> StreamManyArgs6(object n1, object n2, object n3, object n4, object n5, object n6)
        {
            return StreamManyArgs(new[] { n1, n2, n3, n4, n5, n6 });
        }

        public ChannelReader<object> StreamManyArgs7(object n1, object n2, object n3, object n4, object n5, object n6, object n7)
        {
            return StreamManyArgs(new[] { n1, n2, n3, n4, n5, n6, n7 });
        }

        public ChannelReader<object> StreamManyArgs8(object n1, object n2, object n3, object n4, object n5, object n6, object n7, object n8)
        {
            return StreamManyArgs(new[] { n1, n2, n3, n4, n5, n6, n7, n8 });
        }

        private ChannelReader<object> StreamManyArgs(object[] items)
        {
            var channel = Channel.CreateUnbounded<object>();
            Task.Run(async () =>
            {
                foreach (var item in items)
                {
                    await channel.Writer.WriteAsync(item);
                }
                channel.Writer.TryComplete();
            });
            return channel.Reader;
        }
    }
}
