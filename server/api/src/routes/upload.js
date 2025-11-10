import { Router } from 'express';
import { getPresignedPutUrl, bucket } from '../lib/storage.js';

const router = Router();

router.post('/init', async (req, res, next) => {
  try {
    const { project_id, files, prefix } = req.body || {};
    if (!Array.isArray(files) || files.length === 0) {
      return res.status(400).json({ error: 'files[] required' });
    }
    const pfx = prefix || (project_id ? `projects/${project_id}` : 'uploads');
    const urls = [];
    for (const name of files) {
      const safe = String(name).replace(/[^A-Za-z0-9._-]/g, '_');
      const key = `${pfx}/${Date.now()}_${safe}`;
      const url = await getPresignedPutUrl(key, 900);
      urls.push({ name, key, bucket, url, method: 'PUT' });
    }
    res.json({ uploads: urls });
  } catch (e) { next(e); }
});

export default router;
