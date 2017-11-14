using System;
using System.Collections.Generic;
using System.Linq;
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
            return Clients.Client(Context.Connection.ConnectionId).InvokeAsync("GetNumber", number);
        }

        public Task InvokeGetPerson(Person person)
        {
            return Clients.Client(Context.Connection.ConnectionId).InvokeAsync("GetPerson", person);
        }

        public IEnumerable<Person> SortByName(Person[] people)
        {
            return people.OrderBy(p => p.LastName).ThenBy(p => p.FirstName);
        }
    }
}
