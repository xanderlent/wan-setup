# Wan Video Generation - Podman Setup

Containerized [Wan 2.1](https://github.com/Wan-Video/Wan2.1) / [Wan 2.2](https://github.com/Wan-Video/Wan2.2) video generation with NVIDIA GPU support on Fedora Linux.

## Hardware Requirements

| Model | VRAM | RAM | Resolution |
|-------|------|-----|------------|
| **Wan 2.1** T2V-1.3B | 8GB+ | 16GB | 480p |
| **Wan 2.2** TI2V-5B | 24GB+ | 32GB | 720p |

> **Note**: Most consumer GPUs should use Wan 2.1.

## Prerequisites

```bash
# 1. Verify NVIDIA driver
nvidia-smi

# 2. Install podman and nvidia-container-toolkit
sudo dnf install -y podman
sudo dnf config-manager addrepo --from-repofile \
  https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo
sudo dnf install -y nvidia-container-toolkit

# 3. Generate CDI spec
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml

# 4. Verify GPU access in container
podman run --rm --security-opt=label=disable --device=nvidia.com/gpu=all \
  nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi
```

## Setup

```bash
git clone https://github.com/Man2Dev/wan-setup.git
cd wan-setup
mkdir -p models output
```

---

## Wan 2.1 (Recommended for most GPUs)

### Download & Build

```bash
# Download model (~5GB)
huggingface-cli download Wan-AI/Wan2.1-T2V-1.3B --local-dir ./models/Wan2.1-T2V-1.3B

# Build container
podman build -f Containerfile.wan21 -t wan21 .
```

### Generate Video

```bash
podman run --rm \
  --security-opt=label=disable \
  --device=nvidia.com/gpu=all \
  -v ./models:/app/models:Z \
  -v ./output:/app/output:Z \
  wan21 \
  --task t2v-1.3B \
  --size "832*480" \
  --ckpt_dir /app/models/Wan2.1-T2V-1.3B \
  --offload_model True \
  --t5_cpu \
  --save_file /app/output/video.mp4 \
  --prompt "A serene lake at sunset with mountains in the background"
```

### Supported Resolutions
- `832*480` (landscape)
- `480*832` (portrait)

---

## Wan 2.2 (High-end GPUs only)

### Download & Build

```bash
# Download model (~15-20GB)
huggingface-cli download Wan-AI/Wan2.2-TI2V-5B --local-dir ./models/Wan2.2-TI2V-5B

# Build container
podman build -t wan22 .
```

### Generate Video

```bash
podman run --rm \
  --security-opt=label=disable \
  --device=nvidia.com/gpu=all \
  -v ./models:/app/models:Z \
  -v ./output:/app/output:Z \
  wan22 \
  --task ti2v-5B \
  --size "1280*704" \
  --ckpt_dir /app/models/Wan2.2-TI2V-5B \
  --offload_model True \
  --convert_model_dtype \
  --t5_cpu \
  --save_file /app/output/video.mp4 \
  --prompt "A serene lake at sunset with mountains in the background"
```

### Image-to-Video

```bash
podman run --rm \
  --security-opt=label=disable \
  --device=nvidia.com/gpu=all \
  -v ./models:/app/models:Z \
  -v ./output:/app/output:Z \
  -v /path/to/image.jpg:/app/input.jpg:Z \
  wan22 \
  --task ti2v-5B \
  --size "1280*704" \
  --image /app/input.jpg \
  --ckpt_dir /app/models/Wan2.2-TI2V-5B \
  --offload_model True \
  --convert_model_dtype \
  --t5_cpu \
  --save_file /app/output/video.mp4 \
  --prompt "The scene comes to life"
```

### Supported Resolutions
- `1280*704` (landscape)
- `704*1280` (portrait)

---

## Common Options

| Option | Description |
|--------|-------------|
| `--size` | Video resolution |
| `--frame_num` | Number of frames (must be 4n+1, default: 121) |
| `--offload_model True` | Offload to CPU (saves VRAM) |
| `--t5_cpu` | Run text encoder on CPU |
| `--sample_steps` | Sampling steps (default: 50) |
| `--base_seed` | Random seed (-1 for random) |

## Debugging

```bash
# Interactive shell
podman run -it --rm \
  --security-opt=label=disable \
  --device=nvidia.com/gpu=all \
  -v ./models:/app/models:Z \
  --entrypoint /bin/bash \
  wan22
```

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| "Killed" | Out of RAM | Add swap: `sudo fallocate -l 32G /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile` |
| CUDA OOM | Out of VRAM | Use `--offload_model True --t5_cpu` or switch to Wan 2.1 |
| "could not select device driver" | CDI not configured | Run `sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml` |

## License

This repo: [GPL-3.0-or-later](LICENSE)  
Wan models: [Apache 2.0](https://github.com/Wan-Video/Wan2.2/blob/main/LICENSE.txt)