FROM node:22-alpine AS frontend-build
WORKDIR /ui
COPY src/frontend/starter-web/package*.json ./
RUN npm install
COPY src/frontend/starter-web/ ./
RUN npm run build

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY src/backend/Starter.Bff/Starter.Bff.csproj src/backend/Starter.Bff/
RUN dotnet restore src/backend/Starter.Bff/Starter.Bff.csproj
COPY src/backend/Starter.Bff/ src/backend/Starter.Bff/
COPY --from=frontend-build /ui/dist/ src/backend/Starter.Bff/wwwroot/
RUN dotnet publish src/backend/Starter.Bff/Starter.Bff.csproj -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
ENV ASPNETCORE_HTTP_PORTS=8080
EXPOSE 8080
COPY --from=build /app/publish .
USER $APP_UID
ENTRYPOINT ["dotnet", "Starter.Bff.dll"]
