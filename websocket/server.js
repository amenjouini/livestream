const WebSocket = require('ws');

// Use port 8081 for WebSocket internally
const PORT = 8081;
const wss = new WebSocket.Server({ port: PORT });

console.log(`WebSocket server is running on port: ${PORT}`);

wss.on('connection', (ws) => {
    console.log('A new client connected.');

    ws.on('message', (message) => {
        console.log('Received message:', message);

        // Broadcast the message to all connected clients
        wss.clients.forEach(client => {
            if (client !== ws && client.readyState === WebSocket.OPEN) {
                client.send(message);
                console.log('Sent message to client:', message);
            }
        });
    });

    ws.on('close', () => {
        console.log('A client disconnected.');
    });

    ws.on('error', (error) => {
        console.error('WebSocket error:', error);
    });
});

module.exports = wss;
