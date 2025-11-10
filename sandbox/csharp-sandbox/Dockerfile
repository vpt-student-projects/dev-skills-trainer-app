FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine

RUN apk add --no-cache coreutils bash
RUN dotnet tool install dotnet-script --tool-path /usr/local/bin
RUN chmod -R 755 /usr/local/bin

# Создайте постоянную директорию для кэша dotnet
RUN mkdir -p /var/dotnet-cache && chmod 1777 /var/dotnet-cache

ENV HOME=/var/dotnet-cache
ENV DOTNET_CLI_HOME=/var/dotnet-cache
ENV NUGET_PACKAGES=/var/dotnet-cache/.nuget

# Прогрев кэша
RUN echo 'using System;' > /tmp/warmup.cs && \
    echo 'Console.WriteLine("Ready");' >> /tmp/warmup.cs && \
    dotnet-script /tmp/warmup.cs && \
    rm /tmp/warmup.cs

RUN mkdir -p /tmp && chmod 1777 /tmp
RUN dotnet-script --version

USER nobody
WORKDIR /tmp
CMD ["sleep", "infinity"]