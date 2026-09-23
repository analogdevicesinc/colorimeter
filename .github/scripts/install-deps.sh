#!/bin/bash

set -e

# Manual docker run for amrhf architecture
if [[ "$ARCHITECTURE" == "armhf" ]]; then
    # Start container
    docker run --platform ${PLATFORM} \
        --name debian13-armhf \
        -v "${GITHUB_WORKSPACE}:/workspace/colorimeter" \
        -e ARTIFACT_NAME="Debian-13-armhf.deb" \
        -e CLOUDSMITH_API_KEY="$CLOUDSMITH_API_KEY" \
        -dit ${CONTAINER}
    
    # Install deps
    docker exec \
        debian13-armhf \
        /bin/bash -c "
            set -e
            cd /workspace/colorimeter
            apt-get update && apt-get install -y \
            rpm pybuild-plugin-pyproject dh-python \
            libc6 libxml2-dev libcdk5-dev libaio-dev libusb-1.0-0-dev libserialport-dev \
            libavahi-client-dev bison flex wget graphviz libavahi-common-dev bzip2 curl
            (apt-get install -y policykit-1 || apt-get install -y polkitd pkexec) && \
            apt-get install python3-gi-cairo
        "

    # Install libiio
    if [[ "$STAGE" == "dev" ]]; then
        docker exec \
            -e ARTIFACT_NAME="${ARTIFACT_NAME}" \
            debian13-armhf \
            /bin/bash -c "
                wget https://packages.analog.com/public/raw/versions/libiio-v0~latest/libiio-0.26.g-${ARTIFACT_NAME}
                dpkg -i *.deb
                ldconfig
                apt-get install -y python3-libiio
            "
    else
        docker exec \
            debian13-armhf \
            /bin/bash -c "
                apt-get install -y libiio-dev
                ldconfig
                apt-get install -y python3-libiio
            "
    fi
else
    [[ "$ARCHITECTURE" == "arm64" ]] && SUDO="" || SUDO="sudo"
    
    ${SUDO} apt-get update
    DEBIAN_FRONTEND=noninteractive ${SUDO} apt-get install -y \
            rpm pybuild-plugin-pyproject dh-python \
            libc6 libxml2-dev libcdk5-dev libaio-dev libusb-1.0-0-dev libserialport-dev \
            libavahi-client-dev bison flex wget graphviz libavahi-common-dev bzip2 curl

    (${SUDO} apt-get install -y policykit-1 || ${SUDO} apt-get install -y polkitd pkexec) && \
        ${SUDO} apt-get install python3-gi-cairo
    python3 -m pip install requests

    # Install libiio
    if [[ "$STAGE" == "dev" ]]; then
        wget https://packages.analog.com/public/raw/versions/libiio-v0~latest/libiio-0.26.g-${ARTIFACT_NAME}
          
        ${SUDO} dpkg -i *.deb
        ${SUDO} ldconfig
    else
        ${SUDO} apt-get install -y libiio-dev
        ${SUDO} ldconfig
    fi

    # The libiio comes by default with the package, but for checking
    ${SUDO} apt-get install -y python3-libiio
fi