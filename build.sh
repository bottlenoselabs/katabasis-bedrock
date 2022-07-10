#!/bin/bash


VERSION="$(date +%Y.%-m).$(git rev-list --count $1)"
dotnet build --nologo --verbosity minimal --configuration Release -p:Version=$VERSION
if [[ "$2" == "ubuntu-18.04" ]]; then
    dotnet pack "./src/cs/production/Katabasis.Bedrock/Katabasis.Bedrock.csproj" --nologo --verbosity minimal --configuration Release --no-build -p:PackageVersion="$VERSION"
fi
dotnet pack "./src/cs/production/Katabasis.Bedrock.$3/Katabasis.Bedrock.$3.csproj" --nologo --verbosity minimal --configuration Release --no-build -p:PackageVersion="$VERSION"