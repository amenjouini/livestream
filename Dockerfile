# Base image for Node.js services
FROM node:18.19 as node_base

# Auth service setup
WORKDIR /usr/src/auth
COPY auth/package*.json ./  # Copy package.json for auth
RUN npm install
COPY auth/server.js ./      # Copy auth server code

# WebSocket service setup
WORKDIR /usr/src/websocket
COPY websocket/package*.json ./  # Copy package.json for websocket
RUN npm install && npm install pm2 -g
COPY websocket/server.js ./      # Copy websocket server code

# Base image for NGINX-RTMP
FROM tiangolo/nginx-rtmp as nginx_base
COPY rtmp/nginx.conf /etc/nginx/nginx.conf  # Copy NGINX RTMP config
COPY rtmp/index.html /www/                 # Copy static files

# Final image combining all services
FROM node:18.19

# Install required tools
RUN apt-get update && apt-get install -y nginx && npm install -g pm2

# Copy NGINX configuration and static files from nginx_base
COPY --from=nginx_base /etc/nginx /etc/nginx
COPY --from=nginx_base /www /www

# Copy Node.js services from node_base
COPY --from=node_base /usr/src /usr/src

# Expose the required ports
EXPOSE 8000 8081 1935

# Start all services
CMD ["sh", "-c", "pm2-runtime /usr/src/websocket/server.js & node /usr/src/auth/server.js & nginx -g 'daemon off;'"]
