FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages for C/C++ development and debugging
RUN apt-get update && apt-get install -y \
    build-essential \
    gdb \
    gdbserver \
    git \
    curl \
    wget \
    openssh-server \
    rsync \
    vim \
    python3 \
    python3-pip \
    python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install latest CMake
RUN wget -qO- "https://cmake.org/files/v3.28/cmake-3.28.3-linux-x86_64.tar.gz" | tar --strip-components=1 -xz -C /usr/local

# Install latest Conan using pip
RUN pip3 install --upgrade pip && \
    pip3 install conan

# Set up SSH for remote debugging
RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Create a non-root user for development
RUN useradd -ms /bin/bash developer
RUN echo 'developer:password' | chpasswd
RUN usermod -aG sudo developer

# Create work directory
RUN mkdir -p /home/developer/workspace
WORKDIR /home/developer/workspace

# Give developer user ownership
RUN chown -R developer:developer /home/developer

# Expose ports for SSH and gdbserver
EXPOSE 22 2222 7777

# Start SSH server
CMD ["/usr/sbin/sshd", "-D"]
