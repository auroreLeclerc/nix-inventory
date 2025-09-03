{ pkgs, ... }: {
	imports = [ ./podman.home.nix ];
	config = {
		home.packages = (with pkgs; [ podman-desktop podman-compose ]);
		services.podman = {
			volumes = {
				minio_data = {};
				postgres_data = {};
				deemix_data = {};
			};
			containers = {
				postgres = {
					image = "postgres:16-alpine";
					volumes = ["postgres_data:/var/lib/postgresql/data"];
					environment = {
						POSTGRES_DB = "postgres";
						POSTGRES_USER = "postgres";
						POSTGRES_PASSWORD = "postgres";
					};
					extraPodmanArgs = [
						"--health-cmd 'CMD-SHELL,pg_isready -U postgres -d postgres'"
						"--health-interval 10s"
						"--health-retries 5"
						"--health-timeout 5s"
					];
					network= ["docker-like"];
				};
				minio = { # Storage (for image uploads)
					image = "minio/minio:latest";
					ports = ["9000:9000"];
					exec = "server /data";
					volumes = ["minio_data:/data"];
					environment = {
						MINIO_ROOT_USER = "minioadmin";
						MINIO_ROOT_PASSWORD = "minioadmin";
					};
					network= ["docker-like"];
				};
				chrome = { # Chrome Browser (for printing and previews)
					image = "ghcr.io/browserless/chromium:v2.18.0"; # Upgrading to newer versions causes issues
					environment = {
						TIMEOUT = 10000;
						CONCURRENT = 10;
						TOKEN = "chrome_token";
						EXIT_ON_HEALTH_FAILURE = "true";
						PRE_REQUEST_HEALTH_CHECK = "true";
					};
					network= ["docker-like"];
				};
				reactive-resume = {
					image = "amruthpillai/reactive-resume:latest";
					ports = ["3000:3000"];
					environment = {
						PORT = 3000;
						NODE_ENV = "production";

						# -- URLs --
						PUBLIC_URL = "http://localhost:3000";
						STORAGE_URL = "http://localhost:9000/default";

						# -- Printer (Chrome) --
						CHROME_TOKEN = "chrome_token";
						CHROME_URL = "ws://chrome:3000";

						# -- Database (Postgres) --
						DATABASE_URL = "postgresql://postgres:postgres@postgres:5432/postgres";

						# -- Auth --
						ACCESS_TOKEN_SECRET = "access_token_secret";
						REFRESH_TOKEN_SECRET = "refresh_token_secret";

						# -- Emails --
						MAIL_FROM = "noreply@localhost";

						# -- Storage (Minio) --
						STORAGE_ENDPOINT = "minio";
						STORAGE_PORT = 9000;
						STORAGE_BUCKET = "default";
						STORAGE_ACCESS_KEY = "minioadmin";
						STORAGE_SECRET_KEY = "minioadmin";
						STORAGE_USE_SSL = false;
						STORAGE_SKIP_BUCKET_CHECK = false;
					};
					network= ["docker-like"];
				};
				deemix = {
					image = "ghcr.io/bambanah/deemix:latest";
					ports = ["6595:6595"];
					volumes = [
						"deemix_data:/config"
						"/home/dawn/Musique/Deezer:/downloads"
					];
					environment = {
						PUID = 0;
						PGID = 0;
					};
					network= ["docker-like"];
				};
			};
		};
	};
}