{
  dotnetCorePackages,
  fetchFromForgejo,
  ryubing,
}:

ryubing.override (prev: {
  buildDotnetModule =
    args:
    prev.buildDotnetModule (
      args
      // rec {
        version = "1.3.285";

        src = fetchFromForgejo {
          domain = "git.ryujinx.app";
          owner = "projects";
          repo = "Ryubing";
          tag = "Canary-${version}";
          hash = "sha256-eD9125N+THp8O6cVx1mUJDRzIs+CwGeFFC6+19VPAJw=";
        };

        dotnet-sdk = dotnetCorePackages.sdk_10_0;
        dotnet-runtime = dotnetCorePackages.runtime_10_0;

        nugetDeps = ./ryubing-canary-deps.json;

        meta = args.meta // {
          description = "${args.meta.description} (canary nightly)";
          changelog = "https://git.ryujinx.app/Ryubing/Canary/releases/tag/${version}";
        };
      }
    );
})
