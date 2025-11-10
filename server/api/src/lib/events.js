let wss = null;
let connections = 0;

export function init(wssInstance) {
  wss = wssInstance;
  wss.on('connection', (ws) => {
    connections += 1;
    ws.on('close', () => { connections = Math.max(0, connections - 1); });
    try {
      ws.send(JSON.stringify({ type: 'welcome', ts: Date.now() }));
    } catch {}
  });
}

export function broadcastAll(event) {
  if (!wss) return;
  const data = JSON.stringify(event);
  wss.clients.forEach((client) => {
    try { client.send(data); } catch {}
  });
}

export function broadcastJob(jobId, payload) {
  broadcastAll({ type: 'job.update', job_id: jobId, ...payload, ts: Date.now() });
}

export function getStats() { return { connections }; }
