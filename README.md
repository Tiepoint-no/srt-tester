# SRT Streaming System with FFmpeg and GStreamer

A Docker Compose system for testing SRT (Secure Reliable Transport) streaming. This setup includes:
- **FFmpeg container**: Generates a test video with timecode overlay
- **GStreamer container**: Receives the video stream and forwards it to an SRT server with configurable options

## Features

- Test video generation with customizable resolution and bitrate
- Configurable SRT streaming parameters:
  - URL configuration
  - Encryption support (AES-128/192/256)
  - Latency adjustment
  - Passphrase protection
  - Stream ID routing
  - Connection modes (caller/listener/rendezvous)

## Prerequisites

- Docker
- Docker Compose

## Quick Start

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` to configure your SRT server URL and options (see Configuration section below)

3. Build and start the containers:
   ```bash
   docker-compose up --build
   ```

4. To run in the background:
   ```bash
   docker-compose up -d --build
   ```

5. View logs:
   ```bash
   docker-compose logs -f
   ```

6. Stop the containers:
   ```bash
   docker-compose down
   ```

## Configuration

Edit the `.env` file to customize the system. Here are the key options:

### Video Settings

```env
VIDEO_WIDTH=1280          # Video width in pixels
VIDEO_HEIGHT=720          # Video height in pixels
FRAMERATE=25              # Frames per second
BITRATE=2000k             # Video bitrate
```

### SRT Server Settings

```env
SRT_URL=srt://host.docker.internal:9000    # SRT server URL
USE_SRT_PARAMS=true                         # Use query parameters (true) or bare URL (false)
SRT_MODE=                                   # Connection mode: caller, listener, or rendezvous (leave empty to omit)
SRT_LATENCY=                                # Latency in milliseconds (leave empty to omit)
SRT_STREAMID=                               # Optional stream identifier (leave empty to omit)
```

**Note:**
- When `USE_SRT_PARAMS=false`, only the bare `SRT_URL` is used without any query parameters
- When `USE_SRT_PARAMS=true`, parameters are **only added to the URI if they are explicitly set**
- Leave parameters empty to omit them from the URI completely

### Encryption Settings

```env
ENABLE_ENCRYPTION=false    # Enable/disable encryption
SRT_PASSPHRASE=            # Passphrase (10-79 characters, required if encryption enabled)
SRT_PBKEYLEN=16            # Key length: 16 (AES-128), 24 (AES-192), or 32 (AES-256)
```

## Example Configurations

### Basic Streaming with Mode and Latency

```env
SRT_URL=srt://192.168.1.100:9000
USE_SRT_PARAMS=true
SRT_MODE=caller
SRT_LATENCY=125
ENABLE_ENCRYPTION=false
```

### Bare URL (No Parameters at All)

```env
SRT_URL=srt://192.168.1.100:9000
USE_SRT_PARAMS=false
```
Result: `srt://192.168.1.100:9000`

### URL Without Query Parameters (Let Server Use Defaults)

```env
SRT_URL=srt://192.168.1.100:9000
USE_SRT_PARAMS=true
SRT_MODE=
SRT_LATENCY=
ENABLE_ENCRYPTION=false
```
Result: `srt://192.168.1.100:9000` (same as bare URL)

### Encrypted Streaming

```env
SRT_URL=srt://192.168.1.100:9000
USE_SRT_PARAMS=true
SRT_MODE=caller
SRT_LATENCY=125
ENABLE_ENCRYPTION=true
SRT_PASSPHRASE=mySecurePassphrase123
SRT_PBKEYLEN=32
```

### High Quality Stream

```env
VIDEO_WIDTH=1920
VIDEO_HEIGHT=1080
FRAMERATE=30
BITRATE=5000k
SRT_URL=srt://192.168.1.100:9000
SRT_LATENCY=200
```

## Testing with a Local SRT Server

To test this system, you need an SRT server. Here's how to set up a simple SRT listener using FFplay:

```bash
ffplay -fflags nobuffer -flags low_delay -strict experimental srt://0.0.0.0:9000?mode=listener
```

Or using VLC:
```bash
vlc srt://0.0.0.0:9000?mode=listener
```

If running the SRT server on your host machine, use `host.docker.internal` in the SRT_URL:
```env
SRT_URL=srt://host.docker.internal:9000
```

## Architecture

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────┐
│  FFmpeg         │  UDP    │  GStreamer       │  SRT    │ SRT Server  │
│  (Test Video)   ├────────>│  (Relay)         ├────────>│ (External)  │
│                 │  :5000  │                  │         │             │
└─────────────────┘         └──────────────────┘         └─────────────┘
```

1. FFmpeg generates a test video pattern with timecode
2. Stream is sent via UDP to the GStreamer container
3. GStreamer receives, parses, and forwards to the SRT server with configured options

## Troubleshooting

### Container fails to start
- Check Docker logs: `docker-compose logs`
- Ensure ports are not already in use
- Verify `.env` file syntax

### No video stream
- Verify SRT server is running and accessible
- Check firewall settings
- Ensure SRT_URL is correct
- Review GStreamer logs for connection errors

### Encryption errors
- Ensure passphrase is 10-79 characters
- Verify both sender and receiver use the same passphrase and pbkeylen
- Check that ENABLE_ENCRYPTION is set to `true`

### Stream quality issues
- Increase SRT_LATENCY for unstable networks
- Adjust BITRATE based on network capacity
- Monitor network bandwidth usage

## Advanced Usage

### Custom GStreamer Pipeline

To modify the GStreamer pipeline, edit `gstreamer/receive.sh`. The current pipeline:
- Receives UDP MPEG-TS stream
- Demuxes video (H.264) and audio (AAC)
- Remuxes to MPEG-TS
- Sends via SRT with configured parameters

### Using with Real Cameras

Replace the FFmpeg container with a real camera source by modifying `ffmpeg/stream.sh` or creating a new input service.

## License

This is a reference implementation for testing purposes.
