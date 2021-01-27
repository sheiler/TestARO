FROM registry.access.redhat.com/ubi8/dotnet-31-runtime AS base

LABEL com.redhat.component="rh-dotnet31" \
      name="dotnet/dotnet-31" \
      version="3.1" \
      architecture="x86_64" \
      release="1" \
      io.k8s.display-name=".NET Core 3.1" \
      io.k8s.description="Base imagen." \
      io.openshift.tags="openshift,dotnet,dotnet31"


WORKDIR /app
EXPOSE 8080
EXPOSE 8443

FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build
WORKDIR /src
COPY ["TestARO2/TestARO2.csproj", "TestARO2/"]
RUN dotnet restore "TestARO2/TestARO2.csproj"
COPY . .
WORKDIR "/src/TestARO2"

RUN find -type d -name bin -prune -exec rm -rf {} \; && find -type d -name obj -prune -exec rm -rf {} \;


RUN dotnet build "TestARO2.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "TestARO2.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "TestARO2.dll"]