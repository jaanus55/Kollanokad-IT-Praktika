#!/usr/bin/env bash
# Varundab WordPressi failid ja andmebaasi. Alles hoitakse 5 viimast varukoopiat.
set -euo pipefail
BACKUP_DIR="/srv/backups/wordpress"
WEB1="veeb1.kollanokad.praktika"
WEB2="veeb2.kollanokad.praktika"
DB_HOST="andmebaas.kollanokad.praktika"
DB_NAME="wordpress"
DB_USER="wp_backup"
DB_PASS_FILE="/root/.wp_backup_password"
DATE="$(date +%Y-%m-%d_%H-%M-%S)"
TARGET="$BACKUP_DIR/wp_$DATE"
mkdir -p "$TARGET"

# Failid mõlemast veebiserverist
rsync -a "root@$WEB1:/var/www/wordpress/" "$TARGET/veeb1_files/"
rsync -a "root@$WEB2:/var/www/wordpress/" "$TARGET/veeb2_files/"

# Andmebaas
DB_PASS="$(cat "$DB_PASS_FILE")"
mysqldump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" | gzip > "$TARGET/wordpress.sql.gz"

tar -C "$BACKUP_DIR" -czf "$TARGET.tar.gz" "$(basename "$TARGET")"
rm -rf "$TARGET"
ls -1t "$BACKUP_DIR"/wp_*.tar.gz | tail -n +6 | xargs -r rm -f
echo "Valmis: $TARGET.tar.gz"
