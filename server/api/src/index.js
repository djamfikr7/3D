import 'dotenv/config';
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import { rateLimiters } from './lib/rate.js';
import { authMiddleware } from './lib/auth.js';
import jobsRouter from './routes/jobs.js';
import exportsRouter from './routes/exports.js';
import devRouter from './routes/dev.js';
import { createServer } from 'http';
import { WebSocketServer } from 'ws';
import path from 'path';
import { fileURLToPath } from 'url';
import { init as initEvents, getStats } from './lib/events.js';

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

if (process.env.NODE_ENV !== 'production') {
  app.use('/dev', devRouter);
}

// Error handler
app.use((err, req, res, next) => {
  console.error('[error]', err);
  res.status(err.status || 500).json({ error: err.message || 'Internal error' });
});

const server = createServer(app);
const wss = new WebSocketServer({ server, path: '/events' });
initEvents(wss);

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
app.use('/public', express.static(path.join(__dirname, 'public')));
app.get('/events/stats', (req, res) => res.json(getStats()));

import { runMigrations } from './db/migrate.js';

(async () => {
  if (process.env.NODE_ENV !== 'production') {
    try { await runMigrations(); console.log('DB migrations up to date'); } catch (e) { console.error('Migration error', e); }
  }
  const PORT = process.env.PORT || 8080;
  server.listen(PORT, () => console.log(`API listening on :${PORT}`));
})();
