// In-memory FIFO queue for dev
const jobs = new Map(); // id -> {id, state, progressPct, payload}
const fifo = [];

export async function enqueueJob(payloadWithId) {
  const { id, ...payload } = payloadWithId;
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

export async function listJobs(limit = 20, offset = 0) {
  const all = Array.from(jobs.values()).sort((a,b)=> (b.created_at||0) - (a.created_at||0));
  return all.slice(offset, offset+limit).map(j => ({ id: j.id, state: j.state, progressPct: j.progressPct, message: j.message }));
}
