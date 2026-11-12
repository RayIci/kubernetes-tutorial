#!/usr/bin/env bash
# check-prereqs.sh — verifies that this machine can run the Kubernetes tutorial.
#
# Usage:  ./scripts/check-prereqs.sh
#
# It only READS information; it never installs or changes anything.
set -euo pipefail

CLUSTER_NAME="k8s-tutorial"
MIN_MEM_GB=6
MIN_CPUS=4

ok=0; warn=0; fail=0
green() { printf '  \033[32m✔\033[0m %s\n' "$*"; ok=$((ok+1)); }
yellow(){ printf '  \033[33m!\033[0m %s\n' "$*"; warn=$((warn+1)); }
red()   { printf '  \033[31m✘\033[0m %s\n' "$*"; fail=$((fail+1)); }
title() { printf '\n\033[1m%s\033[0m\n' "$*"; }

title "1. Command-line tools"
check_tool() {
  local name="$1" version_cmd="$2" hint="$3"
  if command -v "$name" >/dev/null 2>&1; then
    green "$name found: $(eval "$version_cmd" 2>/dev/null | head -n1)"
  else
    red "$name NOT found — $hint"
  fi
}
check_tool docker  "docker --version"                      "install Docker Desktop and enable WSL integration"
check_tool kind    "kind version"                          "https://kind.sigs.k8s.io/docs/user/quick-start/#installation"
check_tool kubectl "kubectl version --client 2>/dev/null"  "https://kubernetes.io/docs/tasks/tools/"
check_tool helm    "helm version --short"                  "https://helm.sh/docs/intro/install/"
check_tool git     "git --version"                         "sudo apt install git"
check_tool curl    "curl --version"                        "sudo apt install curl"

title "2. Docker engine"
if docker info >/dev/null 2>&1; then
  green "Docker daemon is running ($(docker info --format '{{.OperatingSystem}}'))"
  mem_bytes=$(docker info --format '{{.MemTotal}}')
  mem_gb=$(( mem_bytes / 1024 / 1024 / 1024 ))
  cpus=$(docker info --format '{{.NCPU}}')
  if (( mem_gb >= MIN_MEM_GB )); then green "Docker can use ${mem_gb} GB RAM (need >= ${MIN_MEM_GB})"
  else red "Docker can use only ${mem_gb} GB RAM (need >= ${MIN_MEM_GB}) — raise it in Docker Desktop / .wslconfig"; fi
  if (( cpus >= MIN_CPUS )); then green "Docker can use ${cpus} CPUs (need >= ${MIN_CPUS})"
  else yellow "Docker can use only ${cpus} CPUs (recommended >= ${MIN_CPUS})"; fi
else
  red "Docker daemon is NOT reachable — start Docker Desktop"
fi

title "3. Host ports we plan to use for the API gateway"
port_in_use() {
  # Checks both Docker-published ports and local listeners.
  local p="$1"
  docker ps --format '{{.Ports}}' 2>/dev/null | grep -Eq "(:|^)${p}->" && return 0
  command -v ss >/dev/null 2>&1 && ss -ltnH 2>/dev/null | awk '{print $4}' | grep -Eq "[:.]${p}$" && return 0
  return 1
}
for pair in 80:9080 443:9443; do
  p="${pair%%:*}"; fallback="${pair##*:}"
  if port_in_use "$p"; then yellow "port $p is busy — Step 03 will fall back to $fallback"
  else green "port $p looks free"; fi
done
if port_in_use 8080; then
  yellow "port 8080 is busy (expected: used by another cluster/app — we will NOT use it)"
fi

title "4. Existing kind clusters"
if command -v kind >/dev/null 2>&1; then
  clusters=$(kind get clusters 2>/dev/null || true)
  if [[ -z "$clusters" ]]; then
    green "no kind clusters yet"
  else
    while read -r c; do
      if [[ "$c" == "$CLUSTER_NAME" ]]; then green "tutorial cluster '$c' exists"
      else yellow "other kind cluster '$c' exists — the tutorial will leave it alone"; fi
    done <<< "$clusters"
  fi
fi

title "Summary"
printf '  %d ok, %d warnings, %d failures\n\n' "$ok" "$warn" "$fail"
(( fail == 0 )) || exit 1
