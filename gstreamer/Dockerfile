FROM ubuntu:22.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install GStreamer and plugins including SRT support
RUN apt-get update && apt-get install -y \
    gstreamer1.0-tools \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    libgstreamer1.0-dev \
    libgstreamer-plugins-bad1.0-0 \
    libsrt-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /app

# Copy the receiving script
COPY receive.sh /app/receive.sh
RUN chmod +x /app/receive.sh

# Expose port for receiving UDP stream
EXPOSE 5000/udp

# Run the receiving script
CMD ["/app/receive.sh"]
