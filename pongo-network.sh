#!/usr/bin/env bash

function pongo_network_export {
  local script_path
  # explicitly resolve the link because realpath doesn't do it on Windows
  script_path=$(test -L "$0" && readlink "$0" || echo "$0")
  LOCAL_PATH=$(dirname "$(realpath "$script_path")")


  # the path where the plugin source is located, as seen from Pongo (this script)
  KONG_TEST_PLUGIN_PATH=$(realpath .)

  # the working directory, which is the path where the plugin-source is located
  # on the host machine. Only if Pongo is running inside docker itself, the
  # PONGO_WD differs from the KONG_TEST_PLUGIN_PATH
  PONGO_WD=$KONG_TEST_PLUGIN_PATH
  if [[ -d "/pongo_wd" ]]; then
    local HOST_PATH
    PONGO_CONTAINER_ID=$(</pongo_wd/.containerid)
    if [[ "$PONGO_CONTAINER_ID" == "" ]]; then
      warn "'/pongo_wd' path is defined, but failed to get the container id from"
      warn "the '/pongo_wd/.containerid' file. Start the Pongo container with"
      warn "'--cidfile \"[plugin-path]/.containerid\"' to set the file."
      warn "If you are NOT running Pongo itself inside a container, then make"
      warn "sure '/pongo_wd' doesn't exist."
    else
      #msg "Pongo container: $PONGO_CONTAINER_ID"
      HOST_PATH=$(docker inspect "$PONGO_CONTAINER_ID" | grep ":/pongo_wd.*\"" | sed -e 's/^[ \t]*//' | sed s/\"//g | grep -o "^[^:]*")
      #msg "Host working directory: $HOST_PATH"
    fi
    if [[ "$HOST_PATH" == "" ]]; then
      warn "Failed to read the container information, could not retrieve the"
      warn "host path of the '/pongo_wd' directory."
      warn "Make sure to start the container running Pongo with:"
      warn "    -v /var/run/docker.sock:/var/run/docker.sock"
      warn "NOTE: make sure you understand the security implications!"
      err "Failed to get container info."
    fi
    if [[ ! $KONG_TEST_PLUGIN_PATH == /pongo_wd ]] && [[ ! ${KONG_TEST_PLUGIN_PATH:0:10} == /pongo_wd/ ]]; then
      err "When Pongo itself runs inside a container, the plugin source MUST be within the '/pongo_wd' path"
    fi
    PONGO_WD=${KONG_TEST_PLUGIN_PATH/\/pongo_wd/${HOST_PATH}}
  fi

  # create unique projectID based on file-path (on the host machine)
  PROJECT_ID=$(echo -n "$PONGO_WD" | md5sum)
  PROJECT_ID="${PROJECT_ID:0:8}"
  PROJECT_NAME_PREFIX="pongo-"
  PROJECT_NAME=${PROJECT_NAME_PREFIX}${PROJECT_ID}

  NETWORK_NAME=pongo-test-network
  SERVICE_NETWORK_PREFIX="pongo-"
  SERVICE_NETWORK_NAME=${SERVICE_NETWORK_PREFIX}${PROJECT_ID}
  echo $SERVICE_NETWORK_NAME
}
pongo_network_export
