#!/bin/bash
set -e

KEY_DIR="/etc/ssh/keys"

if [ -f "$KEY_DIR/ssh_host_rsa_key" ]; then
    cp "$KEY_DIR"/ssh_host_* /etc/ssh/
else
    ssh-keygen -A
    mkdir -p "$KEY_DIR"
    cp /etc/ssh/ssh_host_* "$KEY_DIR/"
fi
########################################
# Check GitHub token
########################################
if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "ERROR: GITHUB_TOKEN is not set."
  exit 1
fi
echo "========== System packages =========="
apt-get update
apt-get install -y --no-install-recommends \
    python3.8 \
    python3.8-dev \
    python3-pip \
    build-essential \
    git \
    libssl-dev \
    libffi-dev \
    ca-certificates \
    curl \
    wget \
    vim \
    tmux \
    procps \
    net-tools \
    cuda-command-line-tools-11-8
ln -sf /usr/bin/python3.8 /usr/bin/python
python -m pip install --upgrade pip setuptools wheel
echo "========== JAX (CUDA 11.8) =========="
pip install --no-cache-dir \
    jaxlib==0.3.25+cuda11.cudnn82 \
    -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
echo "========== PyTorch (CUDA 11.8) =========="
pip install --no-cache-dir \
    torch==2.1.2+cu118 \
    --index-url https://download.pytorch.org/whl/cu118
echo "========== Fix ptxas for XLA =========="
if [ -f /usr/local/lib/python3.8/dist-packages/nvidia/cuda_nvcc/bin/ptxas ]; then
    ln -sf \
      /usr/local/lib/python3.8/dist-packages/nvidia/cuda_nvcc/bin/ptxas \
      /usr/local/bin/ptxas
fi
echo "========== Clone Unified-IO-2 =========="
cd /workspace || cd /
rm -rf unified-io-2
git clone https://${GITHUB_TOKEN}@github.com/TalkShopClub/unified-io-2.git
cd unified-io-2
echo "========== Install Unified-IO-2 =========="
pip install --no-cache-dir --no-deps -r requirements.lock.txt
pip install --no-cache-dir -e .
pip install --no-cache-dir awscli
echo "========== Sanity check =========="
python - << EOF
import torch, jax, shutil
print("torch CUDA:", torch.cuda.is_available())
print("jax devices:", jax.devices())
print("ptxas:", shutil.which("ptxas"))
EOF
echo "========== Setup complete =========="
# Keep container alive (CRITICAL)
sleep infinity
'
exec /usr/sbin/sshd -D
