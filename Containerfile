FROM pytorch/pytorch:2.4.0-cuda12.1-cudnn9-devel

WORKDIR /app

RUN apt-get update && apt-get install -y git ffmpeg libsndfile1 && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/Wan-Video/Wan2.2.git /app

# Install base requirements only (no animate/s2v)
RUN pip install --upgrade pip setuptools wheel ninja numpy && \
    pip install flash-attn --no-build-isolation && \
    pip install -r requirements.txt

ENTRYPOINT ["python", "generate.py"]