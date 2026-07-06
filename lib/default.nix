{
  lib,
  ...
}:
let
  const = import ./const.nix;
in
{
  inherit const;
  impureSopsReading =
    location:
    assert builtins.isString location;
    if lib.inPureEvalMode then
      abort "🙅🏻‍♀️ Impure reading in pure eval mode won't work."
    else if !builtins.pathExists const.AGE_KEY_FILE then
      builtins.trace "💁🏻‍♀️ No sops age keys found, can't eval secrets." ""
    else if !builtins.pathExists location then
      builtins.trace "💁🏻‍♀️ Secrets aren't decrypted on first run." ""
    else
      (builtins.readFile location);
  consoleWarn =
    control: log:
    assert builtins.isBool control;
    assert builtins.isString log;
    if !control then # ugly
      builtins.trace "🙎🏻‍♀️ ${log}" control
    else
      control;
}
