# Base image for Node.js
FROM node:18.19 as node_base

# Auth service setup
WORKDIR /usr/src/auth
COPY auth/package*.json ./
RUN npm install
COPY auth/server.js ./

# WebSocket service setup
WORKDIR /usr/src/websocket
COPY websocket/package*.json ./
RUN npm install && npm install pm2 -g
COPY websocket/server.js ./

# NGINX-RTMP setup
FROM tiangolo/nginx-rtmp as nginx_base
COPY rtmp/nginx.conf /etc/nginx/nginx.conf
COPY rtmp/index.html /www/

# Final container setup
FROM node:18.19
COPY --from=nginx_base /etc/nginx /etc/nginx
COPY --from=nginx_base /www /www
COPY --from=node_base /usr/src /usr/src

# Expose the required ports
EXPOSE 8000 8081 1935

# Start all services
CMD ["sh", "-c", "pm2-runtime /usr/src/websocket/server.js & node /usr/src/auth/server.js & nginx -g 'daemon off;'"]