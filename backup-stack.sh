#!/bin/bash
# /opt/mediastack/backup-stack.sh
set -e

SOURCE_DIR="/opt/mediastack"
BACKUP_TMP="/tmp/mediastack_backup"
REMOTE_USER="admin"
REMOTE_HOST="192.168.1.100" 
REMOTE_PATH="/volume1/backups/mediastack"
RETENTION_DAYS=7

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ARCHIVE_NAME="mediastack_state_${TIMESTAMP}.tar.gz"

mkdir -p "$BACKUP_TMP"
cd "$SOURCE_DIR"
docker compose pause
tar -czf "${BACKUP_TMP}/${ARCHIVE_NAME}" -C "${SOURCE_DIR}" config .env docker-compose.yml libraries.json *.sh *.ps1
docker compose unpause
rsync -avz -e "ssh -o StrictHostKeyChecking=no" --remove-source-files "${BACKUP_TMP}/${ARCHIVE_NAME}" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/"
ssh "${REMOTE_USER}@${REMOTE_HOST}" "find ${REMOTE_PATH} -name 'mediastack_state_*.tar.gz' -type f -mtime +${RETENTION_DAYS} -delete"