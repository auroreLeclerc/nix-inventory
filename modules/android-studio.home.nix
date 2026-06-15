{
  pkgs,
  ...
}:
{
  config = {
    # users.users.dawn.extraGroups = [ "adbusers" ];

    programs.zsh.localVariables = {
      "CHROME_EXECUTABLE" = "${pkgs.chromium}/bin/chromium-browser";
      "CAPACITOR_ANDROID_STUDIO_PATH" = pkgs.android-studio;
      "JAVA_HOME" = pkgs.jdk;
      "ANDROID_HOME" = "/home/dawn/Android/Sdk/";
      "ELECTRON_SKIP_BINARY_DOWNLOAD" = 1;
    };
    home = {
      packages = with pkgs; [
        flutter
        chromium
        jdk
        git-repo
        android-studio
      ];
      file.adb = {
        source = "${pkgs.android-tools}/bin/adb";
        target = "Android/Sdk/platform-tools/adb";
      };
    };
  };
}
