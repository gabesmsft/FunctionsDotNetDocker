FROM mcr.microsoft.com/dotnet/core/sdk:3.0 AS installer-env

COPY . /src/dotnet-function-app
RUN cd /src/dotnet-function-app && \
    mkdir -p /home/site/wwwroot && \
    dotnet publish *.csproj --output /home/site/wwwroot

# To enable ssh & remote debugging on app service change the base image to the one below
# FROM mcr.microsoft.com/azure-functions/dotnet:3.0-appservice
FROM mcr.microsoft.com/azure-functions/dotnet:3.0
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true

COPY --from=installer-env ["/home/site/wwwroot", "/home/site/wwwroot"]

ADD resolv.conf /etc/resolv.conf.override
CMD cp /etc/resolv.conf.override /etc/resolv.conf

RUN apt-get update
RUN apt-get install -y curl
RUN echo "nameserver myDNS\n" > /etc/resolv.conf; \
    export VERSION=$(curl myURL 2>&1 | grep -o -E 'href="([^"#]+)"' | cut -d'"' -f2 | egrep component-[0-9].[0-9].[0-9]$ | cut -d'-' -f3); \
    echo $VERSION
	