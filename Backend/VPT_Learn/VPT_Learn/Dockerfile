# # См. статью по ссылке https://aka.ms/customizecontainer, чтобы узнать как настроить контейнер отладки и как Visual Studio использует этот Dockerfile для создания образов для ускорения отладки.

# # Этот этап используется при запуске из VS в быстром режиме (по умолчанию для конфигурации отладки)
# FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
# USER $APP_UID
# WORKDIR /app
# EXPOSE 8080
# EXPOSE 8081


# # Этот этап используется для сборки проекта службы
# FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
# ARG BUILD_CONFIGURATION=Release
# WORKDIR /src
# COPY ["VPT_Learn/VPT_Learn.csproj", "VPT_Learn/"]
# RUN dotnet restore "./VPT_Learn/VPT_Learn.csproj"
# COPY . .
# WORKDIR "/src/VPT_Learn"
# RUN dotnet build "./VPT_Learn.csproj" -c $BUILD_CONFIGURATION -o /app/build

# # Этот этап используется для публикации проекта службы, который будет скопирован на последний этап
# FROM build AS publish
# ARG BUILD_CONFIGURATION=Release
# RUN dotnet publish "./VPT_Learn.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# # Этот этап используется в рабочей среде или при запуске из VS в обычном режиме (по умолчанию, когда конфигурация отладки не используется)
# FROM base AS final
# WORKDIR /app
# COPY --from=publish /app/publish .
# ENTRYPOINT ["dotnet", "VPT_Learn.dll"]

# Этап 1: Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Копируем csproj и восстанавливаем зависимости
# ПРИМЕЧАНИЕ: файл .csproj находится в корне контекста сборки (./VPT_Learn)
COPY ["VPT_Learn.csproj", "./"]
RUN dotnet restore "VPT_Learn.csproj"

# Копируем весь код и собираем
COPY . .
RUN dotnet build "VPT_Learn.csproj" -c Release -o /app/build

# Этап 2: Publish stage
FROM build AS publish
RUN dotnet publish "VPT_Learn.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Этап 3: Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Устанавливаем curl для healthcheck
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Создаем пользователя non-root для безопасности
RUN adduser --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser


COPY .env .env
# Копируем опубликованные файлы
COPY --from=publish --chown=appuser:appuser /app/publish .

# Настройки ASP.NET Core
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:8080

# Открываем порт
EXPOSE 8080

# Запускаем приложение
ENTRYPOINT ["dotnet", "VPT_Learn.dll"]