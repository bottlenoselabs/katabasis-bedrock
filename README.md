# Katabasis.Bedrock

External C# bindings and/or wrapper projects of C libraries used in [Katabasis](https://github.com/bottlenoselabs/katabasis).
For local development without using NuGet, this repository is a Git submodule in the Katabasis repository.

This repository will be fairly noisy with [`dependabot`](https://github.com/dependabot) creating pull requests daily if their are updates to external repositories.

Versioning is partially based on date and partially based on Git commits: `YYYY.MM.PATCH` where `PATCH` is the number of commits on that branch.

NuGet packages are created with every version and uploaded to MyGet (https://www.myget.org/feed/Packages/bottlenoselabs) and NuGet (https://www.nuget.org/profiles/bottlenoselabs).