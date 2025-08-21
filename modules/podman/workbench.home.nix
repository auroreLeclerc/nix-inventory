{ pkgs, ... }: {
	imports = [ ./podman.home.nix ];
	config = {
		home.packages = (with pkgs; [ podman-desktop podman-compose ]);
		services.podman = {
			volumes = {
				minio_data = {};
				postgres_data = {};
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
					# extraPodmanArgs = [ "--add-host host.docker.internal:host-gateway" ];
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
						# SMTP_URL: smtp://user:pass@smtp:587 # Optional

						# -- Storage (Minio) --
						STORAGE_ENDPOINT = "minio";
						STORAGE_PORT = 9000;
						# STORAGE_REGION = "us-east-1"; # Optional
						STORAGE_BUCKET = "default";
						STORAGE_ACCESS_KEY = "minioadmin";
						STORAGE_SECRET_KEY = "minioadmin";
						STORAGE_USE_SSL = false;
						STORAGE_SKIP_BUCKET_CHECK = false;

						# -- Crowdin (Optional) --
						# CROWDIN_PROJECT_ID:
						# CROWDIN_PERSONAL_TOKEN:

						# -- Email (Optional) --
						# DISABLE_SIGNUPS = true;
						# DISABLE_EMAIL_AUTH = true;

						# -- GitHub (Optional) --
						# GITHUB_CLIENT_ID: github_client_id
						# GITHUB_CLIENT_SECRET: github_client_secret
						# GITHUB_CALLBACK_URL: http://localhost:3000/api/auth/github/callback

						# -- Google (Optional) --
						# GOOGLE_CLIENT_ID: google_client_id
						# GOOGLE_CLIENT_SECRET: google_client_secret
						# GOOGLE_CALLBACK_URL: http://localhost:3000/api/auth/google/callback

						# -- OpenID (Optional) --
						# VITE_OPENID_NAME: OpenID
						# OPENID_AUTHORIZATION_URL:
						# OPENID_CALLBACK_URL: http://localhost:3000/api/auth/openid/callback
						# OPENID_CLIENT_ID:
						# OPENID_CLIENT_SECRET:
						# OPENID_ISSUER:
						# OPENID_SCOPE: openid profile email
						# OPENID_TOKEN_URL:
						# OPENID_USER_INFO_URL:
					};
					network= ["docker-like"];
				};
			};
		};
	};
}