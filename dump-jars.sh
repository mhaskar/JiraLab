#!/usr/bin/env bash
set -euo pipefail

# Containers to harvest from (must match container_name in compose)
CONTAINERS=(
  "jira-713"
  "jira-850"
  "jira-813"
  "jira-94"
  "jira-912"
)

# Paths inside the Jira containers where JARs usually live
JIRA_INSTALL_DIR="/opt/atlassian/jira"
JIRA_HOME_PLUGINS_DIR="/var/atlassian/application-data/jira/plugins"

# Output directory for all JARs
OUTPUT_BASE_DIR="extracted-jars"

# Requires: docker on the host
command -v docker >/dev/null 2>&1 || { echo "docker not found"; exit 1; }

# Clean previous output directory
rm -rf "$OUTPUT_BASE_DIR"
mkdir -p "$OUTPUT_BASE_DIR"

copy_jars_from_container () {
  local cname="$1"
  local outdir="$OUTPUT_BASE_DIR/${cname}-JARs"
  mkdir -p "$outdir"

  echo "[*] Scanning $cname for JARs..."

  # Build a list of jar paths inside the container (ignore permission errors)
  mapfile -t jar_paths < <(docker exec "$cname" sh -c \
    "for p in \"$JIRA_INSTALL_DIR\" \"$JIRA_HOME_PLUGINS_DIR\"; do \
       if [ -d \"\$p\" ]; then \
         find \"\$p\" -type f -name '*.jar' 2>/dev/null; \
       fi; \
     done")

  if [ "${#jar_paths[@]}" -eq 0 ]; then
    echo "    [!] No JARs found in $cname (unexpected)."
    return 0
  fi

  echo "    [+] Found ${#jar_paths[@]} jars; copying to $outdir/"

  # Copy each JAR maintaining a flat layout (dedupe by basename if needed)
  for j in "${jar_paths[@]}"; do
    base="$(basename "$j")"
    # If duplicate filename occurs, prefix with an incrementing number
    dest="$outdir/$base"
    if [ -e "$dest" ]; then
      n=1
      while [ -e "$outdir/${n}-$base" ]; do n=$((n+1)); done
      dest="$outdir/${n}-$base"
    fi
    docker cp "${cname}:${j}" "$dest" >/dev/null
  done

  echo "    [OK] Copied to $outdir/"
}

for c in "${CONTAINERS[@]}"; do
  if docker ps --format '{{.Names}}' | grep -qx "$c"; then
    copy_jars_from_container "$c"
  else
    echo "[!] Container $c not running; skipping."
  fi
done

echo "[*] Summary of extracted JARs:"
for d in "$OUTPUT_BASE_DIR"/*-JARs; do
  if [ -d "$d" ]; then
    jar_count=$(find "$d" -name "*.jar" | wc -l)
    echo "    $(basename "$d"): $jar_count JARs"
  fi
done

echo "[✓] All JARs extracted to $OUTPUT_BASE_DIR/ directory"
echo "[*] Done."
