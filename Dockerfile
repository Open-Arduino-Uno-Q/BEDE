FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Seoul

RUN echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker
RUN echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker

RUN apt update && apt install -y sudo \
	&& 	apt install -y repo gawk wget git diffstat unzip gcc build-essential cpio python3 python3-pip \
		xz-utils debianutils python3-git libsdl1.2-dev xterm zstd tar python-is-python3 vim \
	&& 	apt install -y lib32stdc++6 libncurses6 checkinstall libssl-dev libsqlite3-dev libgdbm-dev \
		libc6-dev libbz2-dev libffi-dev libgmp3-dev libmpfr-dev texinfo flex bison curl locales ssh \
		clang-20 llvm-20 lld-20 lldb-20

RUN locale-gen en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

RUN echo "embedded_builder" > /etc/hostname

RUN echo "embeddedbuild ALL=NOPASSWD: ALL" >> /etc/sudoers

RUN mkdir /var/run/sshd

RUN ssh-keygen -A

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
