# Stage 1: Build the auth service
FROM node:12 AS auth-build
WORKDIR /usr/src/auth
COPY auth/package*.json ./  
RUN npm install
COPY auth/server.js ./  

# Stage 2: Build the RTMP service
FROM tiangolo/nginx-rtmp AS rtmp-build
COPY rtmp/nginx.conf /etc/nginx/nginx.conf  
COPY rtmp/index.html /www/  

# Stage 3: Build the WebSocket service
FROM node:18.19 AS websocket-build
WORKDIR /usr/src/websocket
COPY websocket/package*.json ./  
RUN npm install && npm install pm2 -g
COPY websocket/server.js ./  

# Final stage: Combine everything
FROM node:18.19

# Install Supervisor to manage multiple services
RUN apt-get update && apt-get install -y supervisor

# Set up working directory for all services
WORKDIR /usr/src/app

# Copy over the built auth service
COPY --from=auth-build /usr/src/auth /usr/src/auth

# Copy over the RTMP service
COPY --from=rtmp-build /usr/local/nginx /usr/local/nginx
COPY /tmp /tmp  

# Copy over the WebSocket service
COPY --from=websocket-build /usr/src/websocket /usr/src/websocket

# Set environment variables for paths
ENV PATH="/usr/local/nginx/sbin:/usr/src/websocket/node_modules/.bin:${PATH}"

# Expose necessary ports
EXPOSE 1935 8080 8081

# Start Supervisor to run all services
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
