const impl = (process.env.QUEUE_IMPL || 'dev').toLowerCase();

let adapter;
if (impl === 'sqs') {
  adapter = await import('./sqs.js');
} else {
  adapter = await import('./dev_inmemory.js');
}

export const enqueueJob = adapter.enqueueJob;
export const dequeueNextJob = adapter.dequeueNextJob;
export const updateJobStatus = adapter.updateJobStatus;
export const getJobStatus = adapter.getJobStatus;
