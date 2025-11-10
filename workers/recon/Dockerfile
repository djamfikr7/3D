# Placeholder GPU worker image
FROM nvidia/cuda:12.1.1-base-ubuntu22.04
RUN apt-get update && apt-get install -y python3 python3-pip git && rm -rf /var/lib/apt/lists/*
WORKDIR /worker
COPY requirements.txt ./
RUN pip3 install -r requirements.txt
COPY worker.py ./
CMD ["python3", "worker.py"]
