{
  dotnetCorePackages,
  ryubing,
  ryubingCanarySrc,
}:

ryubing.override (prev: {
  buildDotnetModule =
    args:
    prev.buildDotnetModule (
      args
      // {
        version =
          let
            date = ryubingCanarySrc.lastModifiedDate;
          in
          "${builtins.substring 0 4 date}-${builtins.substring 4 2 date}-${builtins.substring 6 2 date}-${ryubingCanarySrc.shortRev}";

        src = ryubingCanarySrc;

        dotnet-sdk = dotnetCorePackages.sdk_10_0;
        dotnet-runtime = dotnetCorePackages.runtime_10_0;

        nugetDeps = ./ryubing-canary-deps.json;

        postPatch = (args.postPatch or "") + ''
          substituteInPlace \
            Directory.Packages.props \
            src/Ryujinx/Ryujinx.csproj \
            src/Ryujinx.HLE/Ryujinx.HLE.csproj \
            --replace-fail \
              "SkiaSharp.NativeAssets.Linux.NoDependencies" \
              "SkiaSharp.NativeAssets.Linux"
        '';

        meta = args.meta // {
          description = "${args.meta.description} (canary nightly)";
          changelog = "https://git.ryujinx.app/Ryubing/Canary/commit/${ryubingCanarySrc.rev}";
        };
      }
    );
})
