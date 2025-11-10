// Simple in-memory queue for dev; replace with SQS in prod
const jobs = new Map();

export async function enqueueJob(payload) {
  const id = `job_${Date.now()}_${Math.random().toString(36).slice(2,8)}`;
  jobs.set(id, { id, state: 'queued', progressPct: 0, payload });
  // simulate progress
  setTimeout(() => { const j = jobs.get(id); if (j) { j.state = 'processing'; j.progressPct = 10; } }, 200);
  setTimeout(() => { const j = jobs.get(id); if (j) { j.progressPct = 60; } }, 1200);
  setTimeout(() => { const j = jobs.get(id); if (j) { j.state = 'completed'; j.progressPct = 100; } }, 2500);
  return { id };
}

export async function getJobStatus(id) {
  return jobs.get(id);
}
