# Build stage
FROM dart:stable AS build

WORKDIR /app

# Copy functions package
COPY pubspec.yaml ./
COPY lib/ lib/
COPY bin/ bin/

# Get dependencies
RUN dart pub get

# Build the server
RUN dart compile exe bin/server.dart -o bin/server

# Runtime stage
FROM debian:bookworm-slim

# Install ffmpeg and other runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/bash appuser

WORKDIR /app

# Copy the compiled binary
COPY --from=build /app/bin/server /app/bin/server

# Set permissions
RUN chown -R appuser:appuser /app

USER appuser

# Expose port
EXPOSE 8080

# Set environment
ENV PORT=8080

# Run the server
CMD ["/app/bin/server"]
