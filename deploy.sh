#!/bin/bash

# Maintainer: Gani
# GitHub: https://github.com/irfangani/docker-deploy-automation

# Configuration
export TZ="Asia/Jakarta"

# Parse arguments
BASE_DIR=""
REPO_PATH="" # Directory where the docker-compose.yml is located
BRANCH="staging" # Default branch

# Ensure at least the base directory is provided
if [[ $# -lt 1 ]]; then
    echo "Error: Base directory is required."
    echo "Usage: $0 <base-dir> [--repo-path <path>] [--branch <branch>]"
    exit 1
fi

# The first argument is the base directory
BASE_DIR="$1"
shift

# Process optional arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --repo-path)
            REPO_PATH="$2"
            shift 2
            ;;
        --branch)
            BRANCH="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 <base-dir> [--repo-path <path>] [--branch <branch>]"
            exit 1
            ;;
    esac
done

# Default repo path to base directory if not provided
REPO_PATH="${REPO_PATH:-$BASE_DIR}"

LOG_DIR="$BASE_DIR/logs"
LOG_FILE="$LOG_DIR/deploy_$(date '+%Y-%m-%d').log"
RETRY_LIMIT=3
RETRY_DELAY=5

# Ensure log directory exists
if [ ! -d "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR"
fi

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOG_FILE"
}

run_cmd() {
    local cmd="$1"
    log "Executing: $cmd"
    output=$($cmd 2>&1)
    local exit_code=$?

    if [ $exit_code -ne 0 ]; then
        log "Error executing: $cmd"
        log "Error output: $output"
        return $exit_code
    fi

    log "Success: $cmd"
    return 0
}

# Retry function for Docker compose up with configurable attempts and delay
run_with_retry() {
    local cmd="$1"
    local retries=0

    until run_cmd "$cmd"; do
        ((retries++))
        if [ $retries -ge $RETRY_LIMIT ]; then
            log "Error: Command failed after $RETRY_LIMIT attempts: $cmd"
            return 1
        fi
        log "Retrying ($retries/$RETRY_LIMIT) in $RETRY_DELAY seconds..."
        sleep $RETRY_DELAY
    done
}

update_git_repo() {
    cd "$REPO_PATH" || {
        log "Error: Could not access $REPO_PATH"
        exit 1
    }

    # Ensure we're on the correct branch
    local current_branch
    current_branch=$(git symbolic-ref --short HEAD 2>>"$LOG_FILE")
    if [ "$current_branch" != "$BRANCH" ]; then
        run_cmd "git checkout $BRANCH" || exit 1
        log "Switched to branch $BRANCH."
    fi

    run_cmd "git fetch" || exit 1

    # Check for new commits and pull if necessary
    local LOCAL_COMMIT REMOTE_COMMIT
    LOCAL_COMMIT=$(git rev-parse HEAD 2>>"$LOG_FILE")
    REMOTE_COMMIT=$(git rev-parse origin/$BRANCH 2>>"$LOG_FILE")
    if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
        log "New changes detected on $BRANCH."
        run_cmd "git pull origin $BRANCH" || exit 1
        return 0
    fi

    return 1
}

# Docker restart function with retry logic
restart_and_build_docker() {
    cd "$BASE_DIR" || {
        log "Error: Could not access $BASE_DIR"
        exit 1
    }
    log "Rebuild and Restarting Docker containers with latest changes..."

    if run_with_retry "docker compose up -d --build"; then
        run_cmd "docker image prune -f"
        log "Docker containers restarted successfully."
    else
        log "Failed to restart Docker containers after multiple attempts."
        exit 1
    fi
}

# Main deployment sequence
main() {
    if update_git_repo; then
        restart_and_build_docker
    fi
}

main
