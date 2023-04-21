#!/bin/bash

release="stable"
imageBaseName="gtcs2110/cs2110docker"
imageName="${imageBaseName}:${release}"

define() { IFS=$'\n' read -r -d '' "${1}" || true; }

description="Run the CS 2110 Docker container"

usage_text=""
define usage_text <<'EOF'
USAGE:
    ./cs2110docker.sh [start|stop|-it|-h|--help]

OPTIONS:
    start
            Start a new (graphical) container in the background. This is the default if no options
            are provided.
    stop
            Stop and remove any running instances of the container.
    -it
            Start a (non-graphical) interactive shell in a new container.
    -h, --help
            Show this help text.
EOF

print_help() {
  >&2 echo -e "$description\n\n$usage_text"
}

print_usage() {
  >&2 echo "$usage_text"
}

action=""
if [ $# -eq 0 ]; then
  action="start"
elif [ $# -eq 1 ]; then
  case "$1" in
    start)
      action="start"
      ;;
    stop)
      action="stop"
      ;;
    -it)
      action="-it"
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    *)
      >&2 echo "Error: unrecognized argument: $1"
      >&2 echo ""
      print_usage
      exit 1
      ;;
  esac
elif [ $# -gt 1 ]; then
  >&2 echo "Error: too many arguments"
  >&2 echo ""
  print_usage
  exit 1
fi

if ! docker -v >/dev/null; then
  >&2 echo "ERROR: Docker not found. Please install Docker before running this script. Refer to the CS 2110 Docker Guide."
  exit 1
fi

if ! docker container ls >/dev/null; then
  >&2 echo "ERROR: Docker is not currently running. Please start Docker before running this script."
  exit 1
fi

echo "Found Docker Installation. Checking for existing containers."

existingContainers=($(docker ps -a | grep "$imageBaseName" | awk '{print $1}'))
echo "${existingContainers[@]}"
if [ "${#existingContainers[@]}" -ne 0 ]; then
  echo "Found CS 2110 containers. Stopping and removing them."
  docker stop "${existingContainers[@]}" >/dev/null
  docker rm "${existingContainers[@]}" >/dev/null
else
  echo "No existing CS 2110 containers."
fi

if [ "$action" = "stop" ]; then
  echo "Successfully stopped CS 2110 containers"
  exit 0
fi

echo "Pulling down most recent image of $imageName"

if ! docker pull $imageName; then
  >&2 echo "ERROR: Unable to pull down the most recent image of $imageName"
fi

echo "Starting up new CS 2110 Docker Container:"

if ! ipAddress="$(docker-machine ip default 2>/dev/null)"; then
  ipAddress="127.0.0.1"
fi

if command -v docker-machine &> /dev/null; then
  # We're on legacy Docker Toolbox
  # pwd -W doesn't work with Docker Toolbox
  # Extra '/' fixes some mounting issues
  currDir="/$(pwd)"
else
  # pwd -W should correct path incompatibilites on Windows for Docker Desktop users
  currDir="/$(pwd -W 2>/dev/null || pwd)"
fi

if [ "$action" = "-it" ]; then
  if command -v winpty &> /dev/null; then
    # Run with winpty when available
    winpty docker run --rm -p $ipAddress:6901:6901 -p $ipAddress:5901:5901 -v "$currDir":/cs2110/host/ --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -it  --entrypoint //dockerstartup/it_startup.sh "$imageName"
  else
    docker run --rm -p $ipAddress:6901:6901 -p $ipAddress:5901:5901 -v "$currDir":/cs2110/host/ --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -it  --entrypoint //dockerstartup/it_startup.sh "$imageName"
  fi
elif [ "$action" = "start" ]; then
  docker run -d -p $ipAddress:6901:6901 -p $ipAddress:5901:5901 -v "$currDir":/cs2110/host/ --cap-add=SYS_PTRACE --security-opt seccomp=unconfined "$imageName"

  successfulRun=$?

  if [ $successfulRun = 0 ]; then
    echo "Successfully launched CS 2110 Docker container. Please go to http://$ipAddress:6901/ to access it."
  else
    >&2 echo "ERROR: Unable to launch CS 2110 Docker container."
  fi
fi
