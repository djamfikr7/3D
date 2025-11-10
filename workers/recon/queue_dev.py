import time, requests, json
from loguru import logger

class DevQueueAdapter:
    def __init__(self, api_base):
        self.api_base = api_base

    def receive(self):
        r = requests.get(f"{self.api_base}/dev/next-job", timeout=5)
        if r.status_code == 204:
            return None
        r.raise_for_status()
        j = r.json()
        return { 'job': j, 'receipt': None }

    def delete(self, receipt):
        return True
