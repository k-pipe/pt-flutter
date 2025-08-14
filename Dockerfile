# Build stage: obtain Flutter and build web
FROM debian:stable-slim AS build
RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa ca-certificates && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"
RUN flutter channel stable && flutter upgrade
WORKDIR /app
COPY . .
RUN flutter config --enable-web
RUN flutter build web --release

# Runtime: serve with nginx
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
