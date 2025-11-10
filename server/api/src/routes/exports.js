import { Router } from 'express';

const router = Router();

import { pool } from '../lib/db.js';
import { getPresignedGetUrl, STORAGE_DISABLED } from '../lib/storage.js';

router.post('/', async (req, res, next) => {
  try {
    const { job_id, format, options } = req.body || {};
    if (!job_id || !format) return res.status(400).json({ error: 'job_id and format are required' });
    const export_id = `exp_${Date.now()}_${Math.random().toString(36).slice(2,8)}`;
    const key = `exports/${job_id}.${format}`;
    const url = STORAGE_DISABLED ? `http://localhost:8080/public/viewer.html#${encodeURIComponent(key)}` : await getPresignedGetUrl(key, 3600);
    await pool.query('INSERT INTO exports (id, job_id, format, url, size_bytes) VALUES ($1,$2,$3,$4,$5)', [export_id, job_id, format, url, null]);
    res.json({ export_id, url });
  } catch (e) { next(e); }
});

export default router;
