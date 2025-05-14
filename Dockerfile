# Build stage
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine
RUN apk update && \
    apk upgrade --no-cache && \
    # You can specifically try to upgrade libxml2 if you want to be more targeted,
    # but a general upgrade is often better for overall security.
    # If the general 'apk upgrade' doesn't catch it for some reason (it should),
    # you could add: apk add --upgrade libxml2
    # Clean up apk cache
    rm -rf /var/cache/apk/*
COPY --from=build /app/dist /usr/share/nginx/html
# Add nginx configuration if needed
# COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
