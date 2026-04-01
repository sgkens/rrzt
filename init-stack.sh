#!/bin/bash
# /opt/mediastack/init-stack.sh
set -e

ENV_FILE="/opt/mediastack/.env"
PROWLARR_URL="http://localhost:9696/api/v1"

wait_for_file() {
  local container=$1
  local file_pattern=$2
  local max=30
  local attempt=1
  echo "[INFO] Waiting for $container configuration file to generate..."
  while ! docker exec "$container" sh -c "find /config -name '$file_pattern' | grep -q ."; do
    if [ $attempt -ge $max ]; then
      echo "[ERROR] Timeout waiting for $container ($file_pattern)."
      exit 1
    fi
    sleep 2
    ((attempt++))
  done
}

wait_for_file "prowlarr" "config.xml"
wait_for_file "radarr" "config.xml"
wait_for_file "sonarr" "config.xml"
wait_for_file "lidarr" "config.xml"
wait_for_file "readarr" "config.xml"
wait_for_file "bazarr" "config.ini"

# Tautulli check applies only if the Plex profile is loaded
if docker ps | grep -q "tautulli"; then wait_for_file "tautulli" "config.ini"; fi

echo "[INFO] Extracting API keys from internal container states..."
PROWLARR_API_KEY=$(docker exec prowlarr sed -n 's/.*<ApiKey>\(.*\)<\/ApiKey>.*/\1/p' /config/config.xml | tr -d '\r')
RADARR_API_KEY=$(docker exec radarr sed -n 's/.*<ApiKey>\(.*\)<\/ApiKey>.*/\1/p' /config/config.xml | tr -d '\r')
SONARR_API_KEY=$(docker exec sonarr sed -n 's/.*<ApiKey>\(.*\)<\/ApiKey>.*/\1/p' /config/config.xml | tr -d '\r')
LIDARR_API_KEY=$(docker exec lidarr sed -n 's/.*<ApiKey>\(.*\)<\/ApiKey>.*/\1/p' /config/config.xml | tr -d '\r')
READARR_API_KEY=$(docker exec readarr sed -n 's/.*<ApiKey>\(.*\)<\/ApiKey>.*/\1/p' /config/config.xml | tr -d '\r')
BAZARR_API_KEY=$(docker exec bazarr sh -c 'grep "^apikey" $(find /config -name config.ini | head -n 1)' | awk -F'=' '{print $2}' | tr -d ' \r')

TAUTULLI_API_KEY=""
if docker ps | grep -q "tautulli"; then
  TAUTULLI_API_KEY=$(docker exec tautulli sh -c 'grep "^api_key" $(find /config -name config.ini | head -n 1)' | awk -F'=' '{print $2}' | tr -d ' \r')
fi

link_app() {
  local app=$1
  local url=$2
  local key=$3
  local existing=$(docker exec prowlarr curl -s -X GET "$PROWLARR_URL/applications" -H "X-Api-Key: $PROWLARR_API_KEY")
  if echo "$existing" | grep -q "\"name\": \"$app\""; then return; fi
  docker exec prowlarr curl -s -X POST "$PROWLARR_URL/applications" -H "X-Api-Key: $PROWLARR_API_KEY" -H "Content-Type: application/json" -d '{ "appProfileId": 1, "name": "'"$app"'", "implementation": "'"$app"'", "configContract": "'"${app}Settings"'", "fields": [ { "name": "prowlarrUrl", "value": "http://prowlarr:9696" }, { "name": "baseUrl", "value": "'"$url"'" }, { "name": "apiKey", "value": "'"$key"'" } ], "syncLevel": "fullSync" }' > /dev/null
}

link_app "Radarr" "http://radarr:7878" "$RADARR_API_KEY"
link_app "Sonarr" "http://sonarr:8989" "$SONARR_API_KEY"
link_app "Lidarr" "http://lidarr:8686" "$LIDARR_API_KEY"
link_app "Readarr" "http://readarr:8787" "$READARR_API_KEY"

flaresolverr_check=$(docker exec prowlarr curl -s -X GET "$PROWLARR_URL/indexerproxy" -H "X-Api-Key: $PROWLARR_API_KEY")
if ! echo "$flaresolverr_check" | grep -q "\"name\": \"FlareSolverr\""; then
  docker exec prowlarr curl -s -X POST "$PROWLARR_URL/indexerproxy" -H "X-Api-Key: $PROWLARR_API_KEY" -H "Content-Type: application/json" -d '{ "name": "FlareSolverr", "implementation": "FlareSolverrProxy", "configContract": "FlareSolverrProxySettings", "fields": [ { "name": "host", "value": "http://flaresolverr:8191" } ], "tags": [] }' > /dev/null
fi

link_qbittorrent() {
  local app_name=$1
  local base_url=$2
  local api_key=$3
  local category=$4
  local existing_clients=$(docker exec prowlarr curl -s -X GET "$base_url/api/v3/downloadclient" -H "X-Api-Key: $api_key")
  if echo "$existing_clients" | grep -q "\"name\": \"qBittorrent\""; then return; fi
  local cat_payload=""
  [ "$app_name" == "Radarr" ] && cat_payload='{ "name": "movieCategory", "value": "'"$category"'" }'
  [ "$app_name" == "Sonarr" ] && cat_payload='{ "name": "tvCategory", "value": "'"$category"'" }'
  [ "$app_name" == "Lidarr" ] && cat_payload='{ "name": "musicCategory", "value": "'"$category"'" }'
  [ "$app_name" == "Readarr" ] && cat_payload='{ "name": "bookCategory", "value": "'"$category"'" }'
  docker exec prowlarr curl -s -X POST "$base_url/api/v3/downloadclient" -H "X-Api-Key: $api_key" -H "Content-Type: application/json" -d '{ "enable": true, "name": "qBittorrent", "implementation": "QBittorrent", "configContract": "QBittorrentSettings", "fields": [ { "name": "host", "value": "qbittorrent" }, { "name": "port", "value": 8080 }, { "name": "useSsl", "value": false }, { "name": "username", "value": "admin" }, { "name": "password", "value": "adminadmin" }, '"$cat_payload"' ] }' > /dev/null
}

add_root_folder() {
  local app_name=$1
  local base_url=$2
  local api_key=$3
  local folder_path=$4
  local existing_folders=$(docker exec prowlarr curl -s -X GET "$base_url/api/v3/rootfolder" -H "X-Api-Key: $api_key")
  if echo "$existing_folders" | grep -q "\"path\": \"$folder_path\""; then return; fi
  docker exec prowlarr curl -s -X POST "$base_url/api/v3/rootfolder" -H "X-Api-Key: $api_key" -H "Content-Type: application/json" -d '{ "path": "'"$folder_path"'" }' > /dev/null
}

echo "[INFO] Parsing libraries.json for automated API routing..."
python3 -c '
import sys, json
try:
    data = json.load(sys.stdin)
    for item in data:
        tags = ",".join(item.get("Tags", []))
        print(f"{item[\"Target\"]} {item[\"Category\"]} {tags}")
except Exception as e:
    sys.exit(1)
' < /opt/mediastack/libraries.json | while read -r target category tags; do
  if [[ "$tags" == *"radarr"* ]]; then add_root_folder "Radarr" "http://radarr:7878" "$RADARR_API_KEY" "$target"; link_qbittorrent "Radarr" "http://radarr:7878" "$RADARR_API_KEY" "$category"; fi
  if [[ "$tags" == *"sonarr"* ]]; then add_root_folder "Sonarr" "http://sonarr:8989" "$SONARR_API_KEY" "$target"; link_qbittorrent "Sonarr" "http://sonarr:8989" "$SONARR_API_KEY" "$category"; fi
  if [[ "$tags" == *"lidarr"* ]]; then add_root_folder "Lidarr" "http://lidarr:8686" "$LIDARR_API_KEY" "$target"; link_qbittorrent "Lidarr" "http://lidarr:8686" "$LIDARR_API_KEY" "$category"; fi
  if [[ "$tags" == *"readarr"* ]]; then add_root_folder "Readarr" "http://readarr:8787" "$READARR_API_KEY" "$target"; link_qbittorrent "Readarr" "http://readarr:8787" "$READARR_API_KEY" "$category"; fi
done

echo "[INFO] Provisioning Grafana Dashboards..."
DASHBOARD_DIR="/opt/mediastack/config/grafana/provisioning/dashboards"
mkdir -p "$DASHBOARD_DIR"
if [ ! -f "$DASHBOARD_DIR/docker-metrics.json" ]; then
  curl -s "https://grafana.com/api/dashboards/14282/revisions/latest/download" -o "$DASHBOARD_DIR/docker-metrics.json"
  sed -i 's/"datasource": "${DS_PROMETHEUS}"/"datasource": "Prometheus"/g' "$DASHBOARD_DIR/docker-metrics.json"
  docker restart grafana > /dev/null
fi

echo "[INFO] Interpolating API keys into $ENV_FILE..."
sed -i "s/^RADARR_API_KEY=.*/RADARR_API_KEY=$RADARR_API_KEY/" "$ENV_FILE"
sed -i "s/^SONARR_API_KEY=.*/SONARR_API_KEY=$SONARR_API_KEY/" "$ENV_FILE"
sed -i "s/^LIDARR_API_KEY=.*/LIDARR_API_KEY=$LIDARR_API_KEY/" "$ENV_FILE"
sed -i "s/^READARR_API_KEY=.*/READARR_API_KEY=$READARR_API_KEY/" "$ENV_FILE"
sed -i "s/^PROWLARR_API_KEY=.*/PROWLARR_API_KEY=$PROWLARR_API_KEY/" "$ENV_FILE"
sed -i "s/^BAZARR_API_KEY=.*/BAZARR_API_KEY=$BAZARR_API_KEY/" "$ENV_FILE"
sed -i "s/^TAUTULLI_API_KEY=.*/TAUTULLI_API_KEY=$TAUTULLI_API_KEY/" "$ENV_FILE"

echo "[INFO] Provisioning dependent frontends..."
docker compose -f /opt/mediastack/docker-compose.yml up -d recyclarr homepage unpackerr
echo "[SUCCESS] MediaStack Infrastructure Orchestration Complete."