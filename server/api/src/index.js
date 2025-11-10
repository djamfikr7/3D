import 'dotenv/config';
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import { rateLimiters } from './lib/rate.js';
import pino from 'pino';
import pinoHttp from 'pino-http';
import client from 'prom-client';
import { authMiddleware } from './lib/auth.js';
import jobsRouter from './routes/jobs.js';
import exportsRouter from './routes/exports.js';
import devRouter from './routes/dev.js';
import uploadRouter from './routes/upload.js';
import { createServer } from 'http';
import { WebSocketServer } from 'ws';
import path from 'path';
import { fileURLToPath } from 'url';
import { init as initEvents, getStats } from './lib/events.js';
import { OpenApiValidator } from 'express-openapi-validator';
import pathToOpenAPI from 'path';
import { dashboardAuth } from './middleware/basicAuth.js';

const app = express();
const logger = pino({ level: process.env.LOG_LEVEL || 'info' });
app.use(pinoHttp({ logger }));
app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '10mb' }));

// Metrics setup
client.collectDefaultMetrics();
const httpCounter = new client.Counter({ name: 'api_http_requests_total', help: 'HTTP requests', labelNames: ['method','path','status'] });
app.use((req, res, next) => {
  const end = res.end;
  res.end = function(chunk, encoding, cb){
    try { httpCounter.inc({ method: req.method, path: req.route?.path || req.path, status: res.statusCode }); } catch {}
    return end.call(this, chunk, encoding, cb);
  };
  next();
});
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

app.get('/health', (req, res) => res.json({ ok: true, ts: new Date().toISOString() }));

// OpenAPI validation
import { fileURLToPath as f2u } from 'url';
const __f = f2u(import.meta.url); const __d = path.dirname(__f);
const specPath = path.join(__d, '../openapi.yaml');
try {
  // dynamic import style to avoid breaking dev if spec missing
  // eslint-disable-next-line new-cap
  await new OpenApiValidator({ apiSpec: specPath, validateRequests: true, validateResponses: true }).install(app);
  console.log('OpenAPI validator enabled');
} catch (e) { console.warn('OpenAPI validator not enabled:', e.message); }

app.use(authMiddleware);
app.use(rateLimiters.tierLimiter);

app.use('/process', jobsRouter);
app.use('/status', jobsRouter);
app.use('/export', exportsRouter);
app.use('/upload', uploadRouter);

if (process.env.NODE_ENV !== 'production') {
  app.use('/dev', devRouter);
}

// Error handler compatible with OpenAPI validator
app.use((err, req, res, next) => {
  const status = err.status || err.statusCode || 500;
  const payload = { error: err.message || 'Internal error' };
  if (err.errors) payload.details = err.errors;
  res.status(status).json(payload);
});

const server = createServer(app);
const wss = new WebSocketServer({ server, path: '/events' });
initEvents(wss);

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
app.use('/public', dashboardAuth, express.static(path.join(__dirname, 'public')));
app.get('/events/stats', (req, res) => res.json(getStats()));

import { runMigrations } from './db/migrate.js';

(async () => {
  const NO_DB = String(process.env.NO_DB || '').toLowerCase() === 'true';
  if (!NO_DB && process.env.NODE_ENV !== 'production') {
    try { await runMigrations(); console.log('DB migrations up to date'); } catch (e) { console.error('Migration error', e); }
  } else if (NO_DB) {
    console.log('[dev] NO_DB=true: skipping migrations and DB connectivity checks');
  }
  const PORT = process.env.PORT || 8080;
  server.listen(PORT, () => console.log(`API listening on :${PORT}`));
})();
