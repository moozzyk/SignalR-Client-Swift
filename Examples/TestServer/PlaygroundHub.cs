using System;
using System.Threading.Tasks;
using System.Threading.Channels;
using Microsoft.AspNetCore.SignalR;

namespace TestServer
{
    public class PlaygroundHub : Hub
    {
        private static Random _random = new Random();

        public override Task OnConnectedAsync()
        {
            return Clients.Caller.SendAsync("AddMessage", @"¯\_(ツ)_/¯", "Welcome!");
        }

        public Task Broadcast(string user, string message)
        {
            return Clients.All.SendAsync("AddMessage", user, message);
        }

        public int Add(int n1, int n2)
        {
            return n1 + n2;
        }

        public ChannelReader<int> StreamNumbers(int from, int to)
        {
            var channel = Channel.CreateUnbounded<int>();

            Task.Run(async () =>
            {
                for (; from <= to; from++)
                {
                    await channel.Writer.WriteAsync(from);
                    await Task.Delay(_random.Next(100));
                }

                channel.Writer.TryComplete();
            });

            return channel.Reader;
        }
    }
}
