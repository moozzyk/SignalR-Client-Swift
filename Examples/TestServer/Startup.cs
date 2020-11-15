using System;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.Connections;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

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

        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.UseRouting();
            app.UseEndpoints(endpoints =>
            {
                endpoints.MapConnectionHandler<EchoConnectionHandler>("/echo");
                endpoints.MapConnectionHandler<EchoConnectionHandler>("/echoWebSockets",
                    options => { options.Transports = HttpTransportType.WebSockets; });
                endpoints.MapConnectionHandler<EchoConnectionHandler>("/echoLongPolling",
                    options => { options.Transports = HttpTransportType.LongPolling; });
                endpoints.MapConnectionHandler<EchoConnectionHandler>("/echoNoTransports",
                    options => { options.Transports = HttpTransportType.None; });

                endpoints.MapHub<TestHub>("/testhub");
                endpoints.MapHub<TestHub>("/testhubWebsockets",
                    options => { options.Transports = HttpTransportType.WebSockets; });
                endpoints.MapHub<TestHub>("/testhubLongPolling",
                    options => { options.Transports = HttpTransportType.LongPolling; });

                endpoints.MapHub<ChatHub>("/chat");
                endpoints.MapHub<ChatHub>("/chatWebsockets",
                    options => { options.Transports = HttpTransportType.WebSockets; });
                endpoints.MapHub<ChatHub>("/chatLongPolling",
                    options => { options.Transports = HttpTransportType.LongPolling; });

                endpoints.MapHub<PlaygroundHub>("/playground");
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
