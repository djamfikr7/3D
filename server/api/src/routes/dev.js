import { Router } from 'express';
import { dequeueNextJob, updateJobStatus } from '../lib/queue.js';

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
    if (!updated) return res.status(404).json({ error: 'job not found' });
    res.json({ ok: true });
  } catch (e) { next(e); }
});

export default router;
