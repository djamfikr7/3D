import os, time, json
import requests
from loguru import logger

API_BASE = os.environ.get('API_BASE', 'http://api:8080')

STAGES = [
    ('preprocess', 10, 1.0),
    ('sfm_mvs', 40, 2.0),
    ('meshing', 70, 1.5),
    ('ai_enhance', 90, 2.0),
    ('qa_export', 100, 1.0),
]

def update_status(job_id, state=None, progress=None, message=None):
    payload = { 'id': job_id }
    if state is not None: payload['state'] = state
    if progress is not None: payload['progressPct'] = progress
    if message is not None: payload['message'] = message
    try:
        requests.post(f"{API_BASE}/dev/update-status", json=payload, timeout=5)
    except Exception as e:
        logger.error(f"status update failed: {e}")

def process_job(job):
    job_id = job['id']
    payload = job.get('payload', {})
    logger.info(f"Processing job {job_id} with payload keys: {list(payload.keys())}")
    update_status(job_id, state='processing', progress=0, message='started')
    pct = 0
    for name, target, delay in STAGES:
        time.sleep(delay)
        pct = target
        update_status(job_id, state='processing', progress=pct, message=name)
    update_status(job_id, state='completed', progress=100, message='done')


def main():
    logger.info("Recon worker starting; polling API for jobs...")
    while True:
        try:
            r = requests.get(f"{API_BASE}/dev/next-job", timeout=5)
            if r.status_code == 204:
                time.sleep(2)
                continue
            r.raise_for_status()
            job = r.json()
            process_job(job)
        except requests.RequestException:
            time.sleep(3)
        except Exception as e:
            logger.exception(e)
            time.sleep(2)

if __name__ == '__main__':
    main()
