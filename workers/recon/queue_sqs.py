import boto3, json, time
from loguru import logger

class SQSQueueAdapter:
    def __init__(self, queue_url):
        self.sqs = boto3.client('sqs')
        self.queue_url = queue_url

    def receive(self):
        resp = self.sqs.receive_message(QueueUrl=self.queue_url, MaxNumberOfMessages=1, WaitTimeSeconds=10, VisibilityTimeout=600)
        msgs = resp.get('Messages', [])
        if not msgs:
            return None
        m = msgs[0]
        payload = json.loads(m['Body'])
        job = { 'id': payload.get('id'), 'payload': payload }
        return { 'job': job, 'receipt': m['ReceiptHandle'] }

    def delete(self, receipt):
        if not receipt: return True
        self.sqs.delete_message(QueueUrl=self.queue_url, ReceiptHandle=receipt)
        return True
