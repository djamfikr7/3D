import { Router } from 'express';
import { enqueueJob, getJobStatus } from '../lib/queue/index.js';
import { pool } from '../lib/db.js';

const router = Router();

router.get('/', async (req, res, next) => {
  try {
    const limit = Math.min(Math.max(parseInt(req.query.limit || '20', 10), 1), 100);
    const { rows } = await pool.query('SELECT id, status as state, progress_pct as "progressPct", message FROM jobs ORDER BY created_at DESC LIMIT $1', [limit]);
    res.json(rows);
  } catch (e) { next(e); }
});

router.post('/', async (req, res, next) => {
  try {
    const { project_id, images_manifest, preset, params } = req.body || {};
    if (!project_id || !images_manifest) {
      return res.status(400).json({ error: 'project_id and images_manifest are required' });
    }
    // Create job id and persist
    const id = `job_${Date.now()}_${Math.random().toString(36).slice(2,8)}`;
    await pool.query('INSERT INTO jobs (id, project_id, status, params_json, progress_pct) VALUES ($1,$2,$3,$4,$5)', [id, project_id, 'queued', JSON.stringify(params || {}), 0]);
    // Enqueue
    await enqueueJob({ id, project_id, images_manifest, preset, params });
    return res.status(202).json({ job_id: id, events_url: '/events' });
  } catch (e) { next(e); }
});

router.get('/:job_id', async (req, res, next) => {
  try {
    const id = req.params.job_id;
    const { rows } = await pool.query('SELECT id, status as state, progress_pct as "progressPct", message FROM jobs WHERE id=$1', [id]);
    if (rows.length === 0) {
      const status = await getJobStatus(id);
      if (!status) return res.status(404).json({ error: 'job not found' });
      return res.json(status);
    }
    return res.json(rows[0]);
  } catch (e) { next(e); }
});

router.get('/:job_id/events', async (req, res, next) => {
  try {
    const id = req.params.job_id;
    const { rows } = await pool.query('SELECT state, progress_pct as "progressPct", message, ts FROM job_events WHERE job_id=$1 ORDER BY ts DESC LIMIT 200', [id]);
    res.json(rows);
  } catch (e) { next(e); }
});

export default router;
