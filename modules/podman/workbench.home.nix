{ ... }: {
	imports = [ ./podman.home.nix ];
	config = {
		services.podman = {
			volumes = {
				minio_data = {};
				postgres_data = {};
				deemix_data = {};
				scrutiny_data = {};
				influxdb2_data = {};
			};
			containers = {
				scrutiny = {
					image = "ghcr.io/analogj/scrutiny:master-omnibus	";
					ports = [
						"3002:8080"
						"3003:8086"
					];
					volumes = [
						"/run/udev:/run/udev:ro"
						"scrutiny_data:/opt/scrutiny/config"
						"influxdb2_data:/opt/scrutiny/influxdb"
					];
					environment = {
						PUID = 0;
						PGID = 0;
					};
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				deemix = {
					image = "ghcr.io/bambanah/deemix:latest";
					ports = [ "6595:6595" ];
					volumes = [
						"deemix_data:/config"
						"/home/dawn/Musique/Deezer:/downloads"
					];
					environment = {
						PUID = 0;
						PGID = 0;
					};
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				ollama = {
					image = "docker.io/ollama/ollama:rocm";
					ports = [ "11434:11434" ];
					devices = [
						"/dev/dri:/dev/dri"
						"/dev/kfd:/dev/kfd"
					];
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				open-webui = {
					image = "ghcr.io/open-webui/open-webui:main";
					ports = [ "3001:8080" ];
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				reactive-resume = {
					image = "docker.io/amruthpillai/reactive-resume:latest";
    			ports = [ "3000:3000" ];
					environment = {
						PORT = 3000;
						NODE_ENV = "production";
						PUBLIC_URL = "http://localhost:3000";
						STORAGE_URL = "http://localhost:9000/default";
						CHROME_TOKEN = "chrome_token";
						CHROME_URL = "ws://chrome:3000";
						DATABASE_URL = "postgresql://postgres:postgres@postgres:5432/resume";
						ACCESS_TOKEN_SECRET = "access_token_secret";
						REFRESH_TOKEN_SECRET = "refresh_token_secret";
						MAIL_FROM = "noreply@localhost.gay";
						STORAGE_ENDPOINT = "minio";
						STORAGE_PORT = 9000;
						STORAGE_BUCKET = "default";
						STORAGE_ACCESS_KEY = "minioadmin";
						STORAGE_SECRET_KEY = "minioadmin";
						STORAGE_USE_SSL = false;
						STORAGE_SKIP_BUCKET_CHECK = false;
					};
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				postgres = {
					image = "localhost/homemanager/postgres";
					volumes = [ "postgres_data:/var/lib/postgresql/data" ];
					environment = {
						POSTGRES_PASSWORD = "postgres";
					};
					extraPodmanArgs = [
						"--health-cmd 'pg_isready -U postgres -d postgres'"
						"--health-interval 10s"
						"--health-retries 5"
						"--health-timeout 5s"
					];
					network = [ "docker-like" ];
					autoUpdate = "local";
				};
				minio = { # Storage (for image uploads)
					image = "docker.io/minio/minio:latest";
					volumes = [ "minio_data:/data" ];
					exec = "server /data";
    			ports = [ "9000:9000" ];
					environment = {
						MINIO_ROOT_USER = "minioadmin";
						MINIO_ROOT_PASSWORD = "minioadmin";
					};
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				chrome = { # Chrome Browser (for printing and previews)
					image = "ghcr.io/browserless/chromium:latest";
					environment = {
						TOKEN = "chrome_token";
      			HEALTH = "true";
					};
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
			};
		};
	};
}