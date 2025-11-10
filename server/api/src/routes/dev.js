import { Router } from 'express';
import { dequeueNextJob, updateJobStatus } from '../lib/queue/index.js';

const router = Router();

router.get('/next-job', async (req, res, next) => {
  try {
    const job = await dequeueNextJob();
    if (!job) return res.status(204).send();
    res.json(job);
  } catch (e) { next(e); }
});

router.post('/update-status', async (req, res, next) => {
  try {
    const { id, state, progressPct, message } = req.body || {};
    if (!id) return res.status(400).json({ error: 'id required' });
    const updated = await updateJobStatus(id, { state, progressPct, message });
    // persist to DB as well
    try {
      const fields = [];
      const values = [];
      let idx = 1;
      if (state) { fields.push(`status=$${idx++}`); values.push(state); }
      if (typeof progressPct === 'number') { fields.push(`progress_pct=$${idx++}`); values.push(progressPct); }
      if (message) { fields.push(`message=$${idx++}`); values.push(message); }
      fields.push(`updated_at=now()`);
      if (fields.length) {
        await (await import('../lib/db.js')).pool.query(`UPDATE jobs SET ${fields.join(', ')} WHERE id=$${idx}`, [...values, id]);
      }
    } catch (e) { /* ignore db update errors in dev */ }
    // broadcast event
    try {
      const { broadcastJob } = await import('../lib/events.js');
      broadcastJob(id, { state, progressPct, message });
    } catch {}
    if (!updated) return res.status(404).json({ error: 'job not found' });
    res.json({ ok: true });
  } catch (e) { next(e); }
});

export default router;
