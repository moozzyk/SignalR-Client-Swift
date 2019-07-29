using System;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.Connections;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace TestServer
{
    public class Startup
    {
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddConnections();
            services.AddSignalR(options =>
            {
                options.EnableDetailedErrors = true;
            });
            services.AddSingleton<EchoConnectionHandler>();
        }

        public void Configure(IApplicationBuilder app, IHostingEnvironment env, ILoggerFactory loggerFactory)
        {
            loggerFactory.AddConsole(LogLevel.Debug);

            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.UseConnections(options => options.MapConnectionHandler<EchoConnectionHandler>("/echo"));
            app.UseConnections(options => options.MapConnectionHandler<EchoConnectionHandler>("/echoNoTransports",
                dispatcherOptions =>
                {
                    dispatcherOptions.Transports = HttpTransportType.None;
                }));

            app.UseSignalR(options =>
            {
                options.MapHub<TestHub>("/testhub");
                options.MapHub<ChatHub>("/chat");
                options.MapHub<PlaygroundHub>("/playground");
            });

            app.UseFileServer();

            app.Run(async (context) =>
            {
                if (context.Request.Path.Value.Contains("/throw"))
                {
                    throw new InvalidOperationException("Unexpected error");
                }

                await context.Response.WriteAsync("Hello World!");
            });
        }
    }
}
