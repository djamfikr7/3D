import 'dotenv/config';
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import { rateLimiters } from './lib/rate.js';
import { authMiddleware } from './lib/auth.js';
import jobsRouter from './routes/jobs.js';
import exportsRouter from './routes/exports.js';
import { createServer } from 'http';
import { WebSocketServer } from 'ws';

const app = express();
app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '10mb' }));

app.get('/health', (req, res) => res.json({ ok: true, ts: new Date().toISOString() }));

app.use(authMiddleware);
app.use(rateLimiters.tierLimiter);

app.use('/process', jobsRouter);
app.use('/status', jobsRouter);
app.use('/export', exportsRouter);

// Error handler
app.use((err, req, res, next) => {
  console.error('[error]', err);
  res.status(err.status || 500).json({ error: err.message || 'Internal error' });
});

const server = createServer(app);
const wss = new WebSocketServer({ server, path: '/events' });

wss.on('connection', (ws) => {
  ws.send(JSON.stringify({ type: 'welcome', ts: Date.now() }));
});

const PORT = process.env.PORT || 8080;
server.listen(PORT, () => console.log(`API listening on :${PORT}`));
