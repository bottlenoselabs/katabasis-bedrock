#!/bin/bash
DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
git clone "https://github.com/bottlenoselabs/scripts" "$DIRECTORY/ext/scripts" 2> /dev/null || git -C "$DIRECTORY/ext/scripts" pull

VERSION="$(date +%Y.%-m).$(git rev-list --count $1)"
dotnet build --nologo --verbosity minimal --configuration Release -p:Version=$VERSION
if [[ "$2" == "ubuntu-18.04" ]]; then
    dotnet pack "./src/cs/production/Katabasis.Bedrock/Katabasis.Bedrock.csproj" --nologo --verbosity minimal --configuration Release --no-build -p:PackageVersion="$VERSION"
fi
dotnet pack "./src/cs/production/Katabasis.Bedrock.$3/Katabasis.Bedrock.$3.csproj" --nologo --verbosity minimal --configuration Release --no-build -p:PackageVersion="$VERSION"