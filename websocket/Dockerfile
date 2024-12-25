# Use the official Node.js image as the base image
FROM node:18.19

# Create and set the working directory
WORKDIR /usr/src/app

# Copy the package.json and package-lock.json files
COPY package*.json ./

# Install dependencies, including PM2 globally
RUN npm install && npm install pm2 -g

# Copy the rest of the application files
COPY . .

# Expose the WebSocket server port
EXPOSE 8081

# Start the application using PM2
CMD ["pm2-runtime", "server.js"]
