{
  buildDotnetModule,
  dotnetCorePackages,
  fetchgit,
  lib,
}:

let
  # per CI run rather than per commit
  version = "0.21.0-alpha.133";
in
buildDotnetModule {
  pname = "Ryujinx.LibHac";
  inherit version;

  # 23e402eb
  src = fetchgit {
    url = "https://starforgejo.dev/archive/LibHac_Ryubing";
    rev = "aa8a40f410f7b9fc7b6eee5107bf66821d0ecef6";
    hash = "sha256-1SCEizAelLqX53YroI+Tt1ivOrQWqVGLQfrgWr9rgNI=";
  };

  projectFile = "src/LibHac/LibHac.csproj";
  nugetDeps = ./ryubing-libhac-deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dontPublish = true;
  executables = [ ];
  packNupkg = true;

  dotnetPackFlags = [ "-p:Version=${version}" ];

  meta = {
    description = "Library that reimplements portions of the Nintendo Switch OS, as used by Ryubing";
    homepage = "https://starforgejo.dev/archive/LibHac_Ryubing";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
