# Base image for Node.js services
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

# Base image for NGINX-RTMP
FROM tiangolo/nginx-rtmp as nginx_base
COPY rtmp/nginx.conf /etc/nginx/nginx.conf  
COPY rtmp/index.html /www/                 

# Final image combining all services
FROM tiangolo/nginx-rtmp

# Copy Node.js services from node_base
COPY --from=node_base /usr/src /usr/src

# Copy NGINX configuration and static files from nginx_base
COPY --from=nginx_base /etc/nginx /etc/nginx
COPY --from=nginx_base /www /www

# Install pm2 for Node.js services
RUN apt-get update && apt-get install -y npm && npm install -g pm2

# Expose the required ports
EXPOSE 8080 8000 8081 1935

# Start all services
CMD ["sh", "-c", "node /usr/src/auth/server.js & pm2-runtime /usr/src/websocket/server.js & nginx -g 'daemon off;'"]
