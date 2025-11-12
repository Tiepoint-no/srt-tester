FROM alpine:3.19

# Install FFmpeg and fonts
RUN apk add --no-cache ffmpeg ttf-dejavu

# Create working directory
WORKDIR /app

# Copy the streaming script
COPY stream.sh /app/stream.sh
RUN chmod +x /app/stream.sh

# Run the streaming script
CMD ["/app/stream.sh"]
