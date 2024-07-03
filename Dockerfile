# Use the Dart image
FROM dart:stable

# Resolve app dependencies
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

# Copy app source code
COPY . .

# Set environment variables
ENV PORT=8080
ENV GOOGLE_APPLICATION_CREDENTIALS=/app/service-account.json

# Copy .env file and service account JSON file
COPY .env .env
COPY service-account.json service-account.json

# AOT compile the application
RUN dart compile exe bin/xwordle.dart -o bin/xwordle

# Start webhook
CMD ["./bin/xwordle"]
