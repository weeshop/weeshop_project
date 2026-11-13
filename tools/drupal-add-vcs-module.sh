#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"

ENV_FILE="../.env"
VCS_MODULES_FILE="../drupal-vcs-modules.sh"

set -a
# shellcheck disable=SC1091
source "$ENV_FILE"
set +a

usage() {
  echo "Usage: $0 <module_name> <branch> [git_url] ..." >&2
  echo "Branch is required." >&2
  echo "Example: $0 address_for_china 1.0.x" >&2
  echo "Example: $0 mobile_number project-update-bot-only-dev git@git.drupal.org:issue/mobile_number-3448775.git" >&2
  exit 1
}

if [[ $# -lt 2 ]]; then
  usage
fi

is_git_url() {
  [[ "$1" == *:* || "$1" == *@* || "$1" == git@* || "$1" == http* ]]
}

default_git_url() {
  echo "git@github.com:solody/drupal-${1}.git"
}

add_to_composer() {
  local module="$1"
  local repo_url="$2"
  local package="drupal/${module}"

  ./docker-exec.sh -u application cli env \
    PACKAGE="$package" \
    REPO_URL="$repo_url" \
    php -r '
$package = getenv("PACKAGE");
$repoUrl = getenv("REPO_URL");
$drupalUrl = "https://packages.drupal.org/8";
$file = "composer.json";

$data = json_decode(file_get_contents($file), true, 512, JSON_THROW_ON_ERROR);
$repos = $data["repositories"] ?? [];
if (!array_is_list($repos)) {
    $repos = array_values($repos);
}

$exclude = [];
$vcsRepos = [];
$otherRepos = [];
$seenVcs = [];

foreach ($repos as $repo) {
    if (($repo["type"] ?? "") === "composer" && ($repo["url"] ?? "") === $drupalUrl) {
        foreach ($repo["exclude"] ?? [] as $item) {
            $exclude[] = $item;
        }
        continue;
    }
    if (($repo["type"] ?? "") === "vcs") {
        $url = $repo["url"] ?? "";
        if ($url === "" || isset($seenVcs[$url])) {
            continue;
        }
        $seenVcs[$url] = true;
        $vcsRepos[] = ["type" => "vcs", "url" => $url];
        continue;
    }
    $otherRepos[] = $repo;
}

if (!in_array($package, $exclude, true)) {
    $exclude[] = $package;
}
sort($exclude);

if (!isset($seenVcs[$repoUrl])) {
    $vcsRepos[] = ["type" => "vcs", "url" => $repoUrl];
}

$data["repositories"] = array_merge(
    [[
        "type" => "composer",
        "url" => $drupalUrl,
        "exclude" => array_values($exclude),
    ]],
    $otherRepos,
    $vcsRepos
);

file_put_contents(
    $file,
    json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . "\n"
);
'
}

write_vcs_modules_file() {
  local body="$1"

  {
    echo '#!/bin/bash'
    echo '# Auto-maintained by tools/drupal-add-vcs-module.sh. Sourced by tools/drupal-replace-modules.sh.'
    echo '# Each line: <module_name> <branch> [git_url]  (branch is required)'
    echo '# Default git_url when omitted: git@github.com:solody/drupal-<module_name>.git'
    echo '# Copy from tools/drupal-vcs-modules.sh.dist if this file is missing.'
    echo
    echo "DRUPAL_VCS_MODULES=\"\$(cat <<'EOF'"
    printf '%s\n' "$body"
    echo 'EOF'
    echo ')"'
  } > "$VCS_MODULES_FILE"
}

format_vcs_module_line() {
  local module="$1"
  local branch="$2"
  local repo_url="$3"
  local default_url
  default_url="$(default_git_url "$module")"

  # Same order as CLI: <module_name> <branch> [git_url]
  if [[ "$repo_url" == "$default_url" ]]; then
    echo "${module} ${branch}"
  else
    echo "${module} ${branch} ${repo_url}"
  fi
}

upsert_vcs_modules_file() {
  local module="$1"
  local branch="$2"
  local repo_url="$3"
  local line body="" name mod_branch mod_url

  line="$(format_vcs_module_line "$module" "$branch" "$repo_url")"

  if [[ -f "$VCS_MODULES_FILE" ]]; then
    # shellcheck disable=SC1091
    source "$VCS_MODULES_FILE"
    while read -r name mod_branch mod_url; do
      [[ -z "${name:-}" || "$name" =~ ^# ]] && continue
      [[ "$name" == "$module" ]] && continue
      mod_url="${mod_url:-$(default_git_url "$name")}"
      body+="$(format_vcs_module_line "$name" "$mod_branch" "$mod_url")"$'\n'
    done <<< "${DRUPAL_VCS_MODULES:-}"
  fi

  body+="${line}"
  write_vcs_modules_file "$body"
}

add_module() {
  local module="${1#drupal/}"
  local branch="$2"
  local repo_url="${3:-$(default_git_url "$module")}"

  if [[ -z "$branch" || "$branch" == -* ]]; then
    echo "Branch is required for module ${module}." >&2
    usage
  fi

  add_to_composer "$module" "$repo_url"
  upsert_vcs_modules_file "$module" "$branch" "$repo_url"

  echo "Added drupal/${module} -> ${repo_url} (branch ${branch})"
}

# <module_name> <branch> [git_url] ...
while [[ $# -ge 2 ]]; do
  module_name="$1"
  branch="$2"
  shift 2

  if [[ -z "$branch" ]] || is_git_url "$branch"; then
    echo "Branch is required as the second argument (got: ${branch:-empty})." >&2
    usage
  fi

  git_url="$(default_git_url "${module_name#drupal/}")"
  if [[ $# -ge 1 ]] && is_git_url "$1"; then
    git_url="$1"
    shift
  fi

  add_module "$module_name" "$branch" "$git_url"
done
