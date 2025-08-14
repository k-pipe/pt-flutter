# ===== Stage 1: Build Flutter Web App =====
FROM cirrusci/flutter:stable as build

WORKDIR /app

# Copy Flutter project
COPY . .

# Enable web support and build
RUN flutter config --enable-web \
    && flutter pub get \
    && flutter build web --release

# ===== Stage 2: Serve with Nginx =====
FROM nginx:stable-alpine

# Remove default nginx web files
RUN rm -rf /usr/share/nginx/html/*

# Copy Flutter build output
COPY --from=build /app/build/web /usr/share/nginx/html

# Replace default nginx.conf with AIO disabled
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx with aio=off
CMD ["nginx", "-g", "aio=off; daemon off;"]