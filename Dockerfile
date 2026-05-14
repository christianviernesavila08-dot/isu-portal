# 1. Build Stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy the project file and restore dependencies
# Adjusting path to match your 'backend/IsuBackend/' structure
COPY ["backend/IsuBackend/IsuBackend.csproj", "backend/IsuBackend/"]
RUN dotnet restore "backend/IsuBackend/IsuBackend.csproj"

# Copy everything else and build
COPY . .
WORKDIR "/src/backend/IsuBackend"
RUN dotnet build "IsuBackend.csproj" -c Release -o /app/build

# 2. Publish Stage
FROM build AS publish
RUN dotnet publish "IsuBackend.csproj" -c Release -o /app/publish /p:UseAppHost=false

# 3. Final Runtime Stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Tell .NET to listen on the port Render expects
ENV ASPNETCORE_URLS=http://+:5138
EXPOSE 5138

ENTRYPOINT ["dotnet", "IsuBackend.dll"]