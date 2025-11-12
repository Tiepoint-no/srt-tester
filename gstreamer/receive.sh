#!/bin/bash

# Configuration with defaults
INPUT_PORT=${INPUT_PORT:-5000}
SRT_URL=${SRT_URL:-srt://srt-server:9000}
USE_SRT_PARAMS=${USE_SRT_PARAMS:-true}
SRT_MODE=${SRT_MODE:-caller}
SRT_LATENCY=${SRT_LATENCY:-125}
SRT_STREAMID=${SRT_STREAMID:-}
ENABLE_ENCRYPTION=${ENABLE_ENCRYPTION:-false}
SRT_PASSPHRASE=${SRT_PASSPHRASE:-}
SRT_PBKEYLEN=${SRT_PBKEYLEN:-16}

echo "==========================================="
echo "GStreamer SRT Relay Configuration"
echo "==========================================="
echo "Input: UDP port ${INPUT_PORT}"
echo "Output: ${SRT_URL}"
echo "Use SRT Parameters: ${USE_SRT_PARAMS}"
if [ "${USE_SRT_PARAMS}" = "true" ]; then
    echo "SRT Mode: ${SRT_MODE}"
    echo "SRT Latency: ${SRT_LATENCY} ms"
    echo "Encryption: ${ENABLE_ENCRYPTION}"
    if [ "${ENABLE_ENCRYPTION}" = "true" ]; then
        echo "PBKeyLen: ${SRT_PBKEYLEN}"
        if [ -n "${SRT_PASSPHRASE}" ]; then
            echo "Passphrase: ***set***"
        else
            echo "Passphrase: ***not set***"
        fi
    fi
    if [ -n "${SRT_STREAMID}" ]; then
        echo "Stream ID: ${SRT_STREAMID}"
    fi
fi
echo "==========================================="

# Build SRT URI
if [ "${USE_SRT_PARAMS}" = "true" ]; then
    # Build SRT URI with query parameters
    FULL_SRT_URI="${SRT_URL}?mode=${SRT_MODE}&latency=${SRT_LATENCY}"

    if [ "${ENABLE_ENCRYPTION}" = "true" ]; then
        if [ -z "${SRT_PASSPHRASE}" ]; then
            echo "ERROR: Encryption enabled but no passphrase provided!"
            exit 1
        fi
        FULL_SRT_URI="${FULL_SRT_URI}&passphrase=${SRT_PASSPHRASE}&pbkeylen=${SRT_PBKEYLEN}"
    fi

    if [ -n "${SRT_STREAMID}" ]; then
        FULL_SRT_URI="${FULL_SRT_URI}&streamid=${SRT_STREAMID}"
    fi
else
    # Use bare SRT URL without parameters
    FULL_SRT_URI="${SRT_URL}"
fi

# Wait a bit for the FFmpeg container to start
echo "Waiting for FFmpeg stream..."
sleep 5

echo "Starting GStreamer pipeline..."
echo "Full SRT URI: ${FULL_SRT_URI}"
echo "==========================================="

# GStreamer pipeline: receive UDP, parse and send to SRT
exec gst-launch-1.0 -v \
    udpsrc port=${INPUT_PORT} \
    ! tsdemux name=demux \
    demux. ! queue ! h264parse ! mpegtsmux name=mux \
    demux. ! queue ! aacparse ! mux. \
    mux. ! queue \
    ! srtsink uri="${FULL_SRT_URI}"
