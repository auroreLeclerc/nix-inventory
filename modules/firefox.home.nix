{ pkgs, unstablePkgs, myLibs, osConfig, lib, ... }:
{
	programs.firefox = {
		enable = true;
		nativeMessagingHosts = [
			unstablePkgs.firefoxpwa
			pkgs.kdePackages.plasma-browser-integration
		];
		languagePacks = [ "fr" "en-GB" ];
		policies = {
			DisableTelemetry = true;
			DisableFirefoxStudies = true;
			FirefoxHome = {
				"SponsoredTopSites" = false;
				"SponsoredPocket" = false;
			};
			Homepage =
				let
					path = (myLibs.impureSopsReading osConfig.sops.secrets.dns.path);
					isPath = (path != "");
				in lib.mkIf isPath {
				"URL" = path;
				"StartPage" = "homepage";
    	};
			Preferences = {
				"cookiebanners.service.mode.privateBrowsing" = 2; # Block cookie banners in private browsing
				"cookiebanners.service.mode" = 2; # Block cookie banners
				"privacy.donottrackheader.enabled" = true;
				"privacy.fingerprintingProtection" = true;
				"privacy.resistFingerprinting" = true;
				"privacy.trackingprotection.emailtracking.enabled" = true;
				"privacy.trackingprotection.enabled" = true;
				"privacy.trackingprotection.fingerprinting.enabled" = true;
				"privacy.trackingprotection.socialtracking.enabled" = true;
				"widget.use-xdg-desktop-portal.file-picker" = 1;
			};
			SearchEngines = {
				Default = "DuckDuckGo";
			};
			ExtensionSettings = {
				"uBlock0@raymondhill.net" = {
					install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
					private_browsing = true;
				};
				"jid1-ZAdIEUB7XOzOJw@jetpack" = {
					install_url = "https://addons.mozilla.org/firefox/downloads/latest/duckduckgo-for-firefox/latest.xpi";
				};
				"addon@darkreader.org" = {
					install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
				};
				"{6AC85730-7D0F-4de0-B3FA-21142DD85326}" = {
					install_url = "https://addons.mozilla.org/firefox/downloads/latest/colorzilla/latest.xpi";
				};
				"{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
					install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
				};
				"plasma-browser-integration@kde.org" = {
					install_url = "https://addons.mozilla.org/firefox/downloads/latest/plasma-integration/latest.xpi";
				};
				"firefoxpwa@filips.si" = {
					install_url = "https://addons.mozilla.org/firefox/downloads/latest/pwas-for-firefox/latest.xpi";
				};
			};
		};
# 		profiles = {
# 			"dawn" = {
# 				bookmarks.configFile = null;
#
# 			};
# 		};
	};
}
