import os, time, json
import requests
from loguru import logger
import boto3
from botocore.config import Config
import json as jsonlib
import os as oslib
try:
    import botocore
except Exception:
    botocore = None

API_BASE = os.environ.get('API_BASE', 'http://api:8080')
QUEUE_IMPL = os.environ.get('QUEUE_IMPL', 'dev').lower()
SQS_URL = os.environ.get('SQS_URL')
S3_ENDPOINT = os.environ.get('S3_ENDPOINT')
S3_ACCESS_KEY = os.environ.get('S3_ACCESS_KEY')
S3_SECRET_KEY = os.environ.get('S3_SECRET_KEY')
S3_BUCKET = os.environ.get('S3_BUCKET', 'capture3d-dev')

s3 = None
if S3_ENDPOINT and S3_ACCESS_KEY and S3_SECRET_KEY:
    s3 = boto3.client('s3', endpoint_url=S3_ENDPOINT, aws_access_key_id=S3_ACCESS_KEY, aws_secret_access_key=S3_SECRET_KEY, config=Config(signature_version='s3v4'))

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
    # Upload a dummy artifact to MinIO/S3
    try:
        if s3:
            key = f"exports/{job_id}.glb"
            body = b"glTF-placeholder"  # placeholder bytes
            s3.put_object(Bucket=S3_BUCKET, Key=key, Body=body, ContentType='model/gltf-binary')
            logger.info(f"Uploaded artifact to s3://{S3_BUCKET}/{key}")
    except Exception as e:
        logger.error(f"artifact upload failed: {e}")
    update_status(job_id, state='completed', progress=100, message='done')


def poll_http_loop():
    logger.info("Recon worker starting; polling API for jobs (dev mode)...")
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

def poll_sqs_loop():
    import boto3
    sqs = boto3.client('sqs')
    logger.info("Recon worker starting; polling SQS for jobs...")
    while True:
        try:
            resp = sqs.receive_message(QueueUrl=SQS_URL, MaxNumberOfMessages=1, WaitTimeSeconds=10, VisibilityTimeout=600)
            msgs = resp.get('Messages', [])
            if not msgs:
                continue
            m = msgs[0]
            payload = jsonlib.loads(m['Body'])
            job = { 'id': payload.get('id'), 'payload': payload }
            process_job(job)
            sqs.delete_message(QueueUrl=SQS_URL, ReceiptHandle=m['ReceiptHandle'])
        except Exception as e:
            logger.exception(e)
            time.sleep(3)

def main():
    if QUEUE_IMPL == 'sqs' and SQS_URL:
        poll_sqs_loop()
    else:
        poll_http_loop()

if __name__ == '__main__':
    main()
