#!/usr/bin/env bash
# Staging has no real email sender: links are written to a 0600 file on the
# host. After tapping "Email me a link" in the app, run this to retrieve it.
#
#   ./ops/fetch_magic_link.sh [email-substring]
set -euo pipefail
MATCH="${1:-}"
SSH=(sshpass -p 'dpw123' ssh -o StrictHostKeyChecking=no -o ConnectTimeout=90
     -o GSSAPIAuthentication=no
     -o "ProxyCommand=nc -X 5 -x 127.0.0.1:6578 %h %p" root@204.152.213.47)
LINE=$("${SSH[@]}" "grep -F -- '${MATCH}' /opt/applications/dsapp/magic-links.txt 2>/dev/null | tail -1" || true)
if [ -z "$LINE" ]; then
  echo "No link found${MATCH:+ for '$MATCH'}. Tap \"Email me a link\" in the app first."
  exit 1
fi
printf '%s\n' "$LINE" | awk -F'\t' '{print "issued: "$1"\nemail:  "$2"\nlink:   "$3}'
