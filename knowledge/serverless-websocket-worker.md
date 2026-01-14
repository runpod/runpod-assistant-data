# WebSocket Worker for Serverless Endpoints

Example for real-time bidirectional communication with a serverless worker, bypassing the REST API.

**Repository**: https://github.com/runpod-workers/worker-websocket

## How It Works

1. Wake the worker via `https://api.runpod.ai/v2/{endpointId}/run`
2. Handler retrieves `RUNPOD_PUBLIC_IP` and `RUNPOD_TCP_PORT_8765` from environment
3. Handler shares connection details via `progress_update`
4. Client fetches IP/port from `https://api.runpod.ai/v2/{endpointId}/status/{request_id}`
5. Client connects via WebSocket
6. Client sends `"shutdown"` when done
7. Server shuts down, handler returns, worker terminates

## Required Configuration

**Expose TCP port**: Serverless Settings → Docker Configuration → Expose TCP Ports → add port `8765`

The environment variable name includes the port: `RUNPOD_TCP_PORT_8765`

## Server (rp_handler.py)

```python
from websocket_server import WebsocketServer
import runpod
import os

shutdown_flag = False

def on_message(client, server, message):
    global shutdown_flag
    print(f"Received: {message}")
    server.send_message(client, f"Echo: {message}")

    if message.strip().lower() == "shutdown":
        print("Shutdown command received. Stopping WebSocket server...")
        shutdown_flag = True
        server.shutdown()

def start_websocket():
    global shutdown_flag
    server = WebsocketServer(host="0.0.0.0", port=8765)
    server.set_fn_message_received(on_message)
    print("WebSocket server started on port 8765...")

    while not shutdown_flag:
        server.run_forever()

    return "WebSocket server stopped successfully"

def handler(event):
    public_ip = os.environ.get('RUNPOD_PUBLIC_IP', 'localhost')
    tcp_port = int(os.environ.get('RUNPOD_TCP_PORT_8765', '8765'))

    runpod.serverless.progress_update(event, f"Public IP: {public_ip}, TCP Port: {tcp_port}")

    result = start_websocket()

    return {
        "message": result,
        "public_ip": public_ip,
        "tcp_port": tcp_port
    }

if __name__ == '__main__':
    runpod.serverless.start({'handler': handler})
```

## Client (client.py)

```python
import asyncio
import websockets

async def client():
    uri = "ws://{PUBLIC_IP}:{TCP_PORT}"
    async with websockets.connect(uri) as websocket:
        await websocket.send("Hello")
        response = await websocket.recv()
        print(f"Received: {response}")

        await websocket.send("shutdown")
        response = await websocket.recv()
        print(f"Received: {response}")

asyncio.run(client())
```

## Dockerfile

```dockerfile
FROM python:3.10-slim
WORKDIR /
COPY requirements.txt /requirements.txt
RUN pip install -r requirements.txt
COPY rp_handler.py /
CMD ["python3", "-u", "rp_handler.py"]
```

## Requirements

```
runpod==1.7.7
websocket-server
asyncio
```
