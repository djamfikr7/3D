import { Router } from 'express';
import { enqueueJob, getJobStatus } from '../lib/queue.js';

const router = Router();

router.post('/', async (req, res, next) => {
  try {
    const { project_id, images_manifest, preset, params } = req.body || {};
    if (!project_id || !images_manifest) {
      return res.status(400).json({ error: 'project_id and images_manifest are required' });
    }
    const job = await enqueueJob({ project_id, images_manifest, preset, params });
    return res.status(202).json({ job_id: job.id, events_url: '/events' });
  } catch (e) { next(e); }
});

router.get('/:job_id', async (req, res, next) => {
  try {
    const status = await getJobStatus(req.params.job_id);
    if (!status) return res.status(404).json({ error: 'job not found' });
    res.json(status);
  } catch (e) { next(e); }
});

export default router;
