using System;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace TestServer
{
    public class Startup
    {
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddConnections();
            services.AddSignalR();
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
            app.UseSignalR(options =>
            {
                options.MapHub<TestHub>("/testhub");
                options.MapHub<ChatHub>("/chat");
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
