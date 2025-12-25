FROM pytorch/pytorch:2.4.0-cuda12.1-cudnn9-devel

WORKDIR /app

RUN apt-get update && apt-get install -y git ffmpeg libsndfile1 && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/Wan-Video/Wan2.2.git /app

# Install with pinned compatible versions
RUN pip install --upgrade pip setuptools wheel ninja numpy && \
    pip install flash-attn --no-build-isolation && \
    pip install transformers==4.49.0 && \
    pip install diffusers==0.31.0 && \
    pip install peft==0.13.2 && \
    pip install -r requirements.txt --no-deps && \
    pip install decord librosa accelerate tokenizers tqdm imageio easydict ftfy dashscope imageio-ffmpeg opencv-python

ENTRYPOINT ["python", "generate.py"]