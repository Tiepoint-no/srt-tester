#!/bin/sh

# Configuration with defaults
OUTPUT_HOST=${OUTPUT_HOST:-gstreamer}
OUTPUT_PORT=${OUTPUT_PORT:-5000}
VIDEO_WIDTH=${VIDEO_WIDTH:-1280}
VIDEO_HEIGHT=${VIDEO_HEIGHT:-720}
FRAMERATE=${FRAMERATE:-25}
BITRATE=${BITRATE:-2000k}

echo "Starting FFmpeg test video stream..."
echo "Streaming to: udp://${OUTPUT_HOST}:${OUTPUT_PORT}"
echo "Resolution: ${VIDEO_WIDTH}x${VIDEO_HEIGHT}"
echo "Framerate: ${FRAMERATE} fps"
echo "Bitrate: ${BITRATE}"

# Generate test video with timecode and stream it via UDP
ffmpeg -re \
  -f lavfi -i "testsrc=size=${VIDEO_WIDTH}x${VIDEO_HEIGHT}:rate=${FRAMERATE}" \
  -f lavfi -i "sine=frequency=1000:sample_rate=48000" \
  -vf "drawtext=fontfile=/usr/share/fonts/ttf-dejavu/DejaVuSans-Bold.ttf:text='Test Video %{localtime\:%X}':x=(w-text_w)/2:y=h-60:fontsize=48:fontcolor=white:box=1:boxcolor=black@0.5:boxborderw=5" \
  -c:v libx264 -preset veryfast -tune zerolatency \
  -b:v ${BITRATE} -maxrate ${BITRATE} -bufsize $((2 * ${BITRATE%k}))k \
  -g $((FRAMERATE * 2)) -keyint_min ${FRAMERATE} \
  -c:a aac -b:a 128k -ar 48000 \
  -f mpegts "udp://${OUTPUT_HOST}:${OUTPUT_PORT}?pkt_size=1316"
