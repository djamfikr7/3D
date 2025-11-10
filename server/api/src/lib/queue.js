// In-memory FIFO queue for dev; replace with SQS in prod
const jobs = new Map(); // id -> {id, state, progressPct, payload}
const fifo = []; // array of job ids

export async function enqueueJob(payload) {
  const id = `job_${Date.now()}_${Math.random().toString(36).slice(2,8)}`;
  const job = { id, state: 'queued', progressPct: 0, payload };
  jobs.set(id, job);
  fifo.push(id);
  return { id };
}

export async function dequeueNextJob() {
  const id = fifo.shift();
  if (!id) return null;
  const job = jobs.get(id);
  if (!job) return null;
  job.state = 'processing';
  return { id: job.id, payload: job.payload };
}

export async function updateJobStatus(id, patch) {
  const job = jobs.get(id);
  if (!job) return null;
  Object.assign(job, patch);
  jobs.set(id, job);
  return job;
}

export async function getJobStatus(id) {
  return jobs.get(id);
}
