#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"

ENV_FILE="../.env"
VCS_PROJECTS_FILE="../drupal-vcs-projects.sh"

set -a
# shellcheck disable=SC1091
source "$ENV_FILE"
set +a

usage() {
  echo "Usage: $0 [--type module|theme|profile] <project_name> <branch> [git_url] ..." >&2
  echo "Branch is required. Default --type is module." >&2
  echo "Example: $0 address_for_china 1.0.x" >&2
  echo "Example: $0 --type theme weeshop_molla 1.0.x" >&2
  echo "Example: $0 --type profile weeshop 1.0.x" >&2
  echo "Example: $0 mobile_number project-update-bot-only-dev git@git.drupal.org:issue/mobile_number-3448775.git" >&2
  exit 1
}

is_git_url() {
  [[ "$1" == *:* || "$1" == *@* || "$1" == git@* || "$1" == http* ]]
}

default_git_url() {
  echo "git@github.com:solody/drupal-${1}.git"
}

project_type_var() {
  case "$1" in
    module) echo DRUPAL_VCS_MODULES ;;
    theme) echo DRUPAL_VCS_THEMES ;;
    profile) echo DRUPAL_VCS_PROFILES ;;
    *)
      echo "Unknown project type: $1 (expected module, theme, or profile)." >&2
      exit 1
      ;;
  esac
}

add_to_composer() {
  local project="$1"
  local repo_url="$2"
  local package="drupal/${project}"

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

format_vcs_project_line() {
  local project="$1"
  local branch="$2"
  local repo_url="$3"
  local default_url
  default_url="$(default_git_url "$project")"

  # Same order as CLI: <project_name> <branch> [git_url]
  if [[ "$repo_url" == "$default_url" ]]; then
    echo "${project} ${branch}"
  else
    echo "${project} ${branch} ${repo_url}"
  fi
}

body_from_list() {
  local list="$1"
  local skip_name="${2:-}"
  local body="" name project_branch project_url

  while read -r name project_branch project_url; do
    [[ -z "${name:-}" || "$name" =~ ^# ]] && continue
    [[ -n "$skip_name" && "$name" == "$skip_name" ]] && continue
    project_url="${project_url:-$(default_git_url "$name")}"
    body+="$(format_vcs_project_line "$name" "$project_branch" "$project_url")"$'\n'
  done <<< "$list"

  printf '%s' "$body"
}

write_vcs_projects_file() {
  local modules_body="$1"
  local themes_body="$2"
  local profiles_body="$3"

  {
    echo '#!/bin/bash'
    echo '# Auto-maintained by tools/drupal-add-vcs-project.sh. Sourced by tools/drupal-replace-projects.sh.'
    echo '# Each line: <project_name> <branch> [git_url]  (branch is required)'
    echo '# Default git_url when omitted: git@github.com:solody/drupal-<project_name>.git'
    echo '#'
    echo '# Copy to project root:'
    echo '#   cp tools/drupal-vcs-projects.sh.dist drupal-vcs-projects.sh'
    echo
    echo "DRUPAL_VCS_MODULES=\"\$(cat <<'EOF'"
    printf '%s' "$modules_body"
    [[ -n "$modules_body" && "$modules_body" != *$'\n' ]] && echo
    echo 'EOF'
    echo ')"'
    echo
    echo "DRUPAL_VCS_THEMES=\"\$(cat <<'EOF'"
    printf '%s' "$themes_body"
    [[ -n "$themes_body" && "$themes_body" != *$'\n' ]] && echo
    echo 'EOF'
    echo ')"'
    echo
    echo "DRUPAL_VCS_PROFILES=\"\$(cat <<'EOF'"
    printf '%s' "$profiles_body"
    [[ -n "$profiles_body" && "$profiles_body" != *$'\n' ]] && echo
    echo 'EOF'
    echo ')"'
  } > "$VCS_PROJECTS_FILE"
}

upsert_vcs_projects_file() {
  local project_type="$1"
  local project="$2"
  local branch="$3"
  local repo_url="$4"
  local line modules_body="" themes_body="" profiles_body=""

  line="$(format_vcs_project_line "$project" "$branch" "$repo_url")"

  if [[ -f "$VCS_PROJECTS_FILE" ]]; then
    # shellcheck disable=SC1091
    source "$VCS_PROJECTS_FILE"
  fi

  local skip_module="" skip_theme="" skip_profile=""
  case "$project_type" in
    module) skip_module="$project" ;;
    theme) skip_theme="$project" ;;
    profile) skip_profile="$project" ;;
  esac

  modules_body="$(body_from_list "${DRUPAL_VCS_MODULES:-}" "$skip_module")"
  themes_body="$(body_from_list "${DRUPAL_VCS_THEMES:-}" "$skip_theme")"
  profiles_body="$(body_from_list "${DRUPAL_VCS_PROFILES:-}" "$skip_profile")"

  case "$project_type" in
    module) modules_body+="${line}"$'\n' ;;
    theme) themes_body+="${line}"$'\n' ;;
    profile) profiles_body+="${line}"$'\n' ;;
  esac

  write_vcs_projects_file "$modules_body" "$themes_body" "$profiles_body"
}

add_project() {
  local project_type="$1"
  local project="${2#drupal/}"
  local branch="$3"
  local repo_url="${4:-$(default_git_url "$project")}"

  if [[ -z "$branch" || "$branch" == -* ]]; then
    echo "Branch is required for ${project_type} ${project}." >&2
    usage
  fi

  project_type_var "$project_type" >/dev/null
  add_to_composer "$project" "$repo_url"
  upsert_vcs_projects_file "$project_type" "$project" "$branch" "$repo_url"

  echo "Added ${project_type} drupal/${project} -> ${repo_url} (branch ${branch})"
}

project_type="module"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --type)
      [[ $# -ge 2 ]] || usage
      project_type="$2"
      project_type_var "$project_type" >/dev/null
      shift 2
      ;;
    --type=*)
      project_type="${1#--type=}"
      project_type_var "$project_type" >/dev/null
      shift
      ;;
    -h|--help)
      usage
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage
      ;;
    *)
      break
      ;;
  esac
done

if [[ $# -lt 2 ]]; then
  usage
fi

# <project_name> <branch> [git_url] ...
while [[ $# -ge 2 ]]; do
  project_name="$1"
  branch="$2"
  shift 2

  if [[ -z "$branch" ]] || is_git_url "$branch"; then
    echo "Branch is required as the second argument (got: ${branch:-empty})." >&2
    usage
  fi

  git_url="$(default_git_url "${project_name#drupal/}")"
  if [[ $# -ge 1 ]] && is_git_url "$1"; then
    git_url="$1"
    shift
  fi

  add_project "$project_type" "$project_name" "$branch" "$git_url"
done
