# Use the Dart image
FROM dart:stable AS build

# Resolve app dependencies
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

# Copy app source code
COPY . .

# Ensure packages are still up-to-date if anything has changed
RUN dart pub get --offline

# Set environment variables
ENV PORT=8080
ENV GOOGLE_APPLICATION_CREDENTIALS=/app/service-account.json
ENV HOST 0.0.0.0

# Copy .env file and service account JSON file
COPY .env .env
COPY service-account.json service-account.json

# AOT compile the application
RUN dart compile exe bin/xwordle.dart -o bin/xwordle

# Build minimal serving image from AOT-compiled `/server` and required system
# libraries and configuration files stored in `/runtime/` from the build stage.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/xwordle /app/bin/
COPY --from=build /app/.env /app/
COPY --from=build /app/service-account.json /app/

# Expose the port
EXPOSE 8080

# Start webhook
CMD ["/app/bin/xwordle"]