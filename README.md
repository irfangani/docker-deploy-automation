
# Docker Deploy Automation

A lightweight and flexible deployment automation script designed for Docker-based projects. This script streamlines the process of pulling updates from a Git repository, rebuilding Docker containers, and restarting services with minimal effort.

## Features

- **Dynamic Configuration**:
  - Mandatory `Base Directory` for deployment operations.
  - Optional `Repo Path` (defaults to the base directory).
  - Optional `Branch` (defaults to `staging`).
  
- **Retry Mechanism**: 
  - Retries failed commands (e.g., Docker rebuild) with a configurable limit and delay.

- **Activity Logging**:
  - Logs all deployment activities to a timestamped file in the `logs` directory.

- **Git Integration**:
  - Automatically detects new commits and pulls changes only when updates are available.

- **Docker Management**:
  - Rebuilds Docker containers and cleans up unused images.

## Usage

### Script Arguments
1. **Base Directory (Required)**: The main directory of your project.
2. **Optional Arguments**:
   - `--repo-path <path>`: Specify the path to the Git repository (defaults to the base directory).
   - `--branch <branch>`: Specify the Git branch (defaults to `staging`).

### Example Commands

1. **Default Repo Path and Branch**:
   ```bash
   ./deploy.sh /home/ubuntu/myproject
   ```
   - Base directory: `/home/ubuntu/myproject`
   - Repo path: `/home/ubuntu/myproject` (default)
   - Branch: `staging` (default)

2. **Custom Repo Path and Default Branch**:
   ```bash
   ./deploy.sh /home/ubuntu/myproject --repo-path /home/ubuntu/repo
   ```
   - Base directory: `/home/ubuntu/myproject`
   - Repo path: `/home/ubuntu/repo`
   - Branch: `staging` (default)

3. **Custom Repo Path and Branch**:
   ```bash
   ./deploy.sh /home/ubuntu/myproject --repo-path /home/ubuntu/repo --branch feature/new-feature
   ```
   - Base directory: `/home/ubuntu/myproject`
   - Repo path: `/home/ubuntu/repo`
   - Branch: `feature/new-feature`

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/docker-deploy-automation.git
   ```
2. Make the script executable:
   ```bash
   chmod +x deploy.sh
   ```
3. Run the script using the usage examples above.

## Logs

Deployment logs are saved daily in the `logs` directory under the specified base directory.  
Example log file: `logs/deploy_YYYY-MM-DD.log`.

## System Requirements

- **Docker & Docker Compose**: Required for building and running containers.
- **Git**: For synchronizing updates from the repository.
- **Bash Shell**: Compatible with Unix-based systems.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
