import { Router } from 'express';

const router = Router();

router.post('/', async (req, res, next) => {
  try {
    const { job_id, format, options } = req.body || {};
    if (!job_id || !format) return res.status(400).json({ error: 'job_id and format are required' });
    // Placeholder: create export record and presigned URL
    res.json({ export_id: `exp_${Date.now()}`, url: `https://example.com/download/${job_id}.${format}` });
  } catch (e) { next(e); }
});

export default router;
