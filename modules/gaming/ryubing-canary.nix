{
  callPackage,
  dotnetCorePackages,
  lib,
  ryubing,
  ryubingCanarySrc,
}:

let
  ryubingLibhac = callPackage ./ryubing-libhac.nix { };

  # LibHacAlpha feed on git.ryujinx.app, which is offline,
  # --replace-fail makes the build complain here if upstream ever moves the feed
  deadFeed = "<add key=\"LibHacAlpha\" value=\"https://git.ryujinx.app/api/packages/projects/nuget/index.json\" />";
  deadFeedMapping = "<packageSource key=\"LibHacAlpha\">\n            <package pattern=\"Ryujinx.LibHac\" />\n        </packageSource>";
in
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

        projectReferences = (args.projectReferences or [ ]) ++ [ ryubingLibhac ];

        postPatch = (args.postPatch or "") + ''
          substituteInPlace \
            Directory.Packages.props \
            src/Ryujinx/Ryujinx.csproj \
            src/Ryujinx.HLE/Ryujinx.HLE.csproj \
            --replace-fail \
              "SkiaSharp.NativeAssets.Linux.NoDependencies" \
              "SkiaSharp.NativeAssets.Linux"

          substituteInPlace nuget.config \
            --replace-fail ${lib.escapeShellArg deadFeed} "" \
            --replace-fail ${lib.escapeShellArg deadFeedMapping} ""
        '';

        meta = args.meta // {
          description = "${args.meta.description} (canary nightly)";
          changelog = "https://starforgejo.dev/archive/Ryubing/Canary/commit/${ryubingCanarySrc.rev}";
        };
      }
    );
})
