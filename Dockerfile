FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04
RUN apt update && apt install -y openssh-server && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/run/sshd /root/.ssh && \
    chmod 700 /root/.ssh
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
EXPOSE 22
RUN echo 'export PATH="/opt/conda/bin:$PATH"' >> /root/.bashrc && \
    echo '. /opt/conda/etc/profile.d/conda.sh' >> /root/.bashrc
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
