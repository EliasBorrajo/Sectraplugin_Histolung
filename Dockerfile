# Dockerfile to create mask3d image as non-root user

FROM nvcr.io/nvidia/cuda:11.3.0-devel-ubuntu20.04

# Not cache pip packages
RUN echo "[install]\ncompile = no\n\n[global]\nno-cache-dir = True" > /etc/pip.conf

# Set timezone to not be imteractive the python installation
ENV TZ=Europe/Madrid

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set non-root user as user
ARG USER_ID
ARG GROUP_ID

RUN apt-get update && \
    apt-get install -y sudo && \
    addgroup --gid $GROUP_ID user && \
    adduser --uid $USER_ID --gid $GROUP_ID --disabled-password --gecos "Default user" user && \
    echo 'user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

USER user

# Install Python and git
RUN sudo apt-get update && \ 
    sudo apt-get install -y python3.9 python3.9-dev python3-pip git-all openslide-tools

ENV PATH=/home/user/.local/bin:$PATH

# Create mask3D appHistolung and output folders
RUN mkdir -p /home/user/appHistolung

# Change Workdirectory to mask3D appHistolung
WORKDIR /home/user/appHistolung

# Copy files into the container and set the appropriate permissions
COPY --chown=user:user . /home/user/appHistolung
RUN chmod -R ug+rwx /home/user/appHistolung

# Create output directory with correct permissions
RUN mkdir -p /home/user/appHistolung/data/outputs && chown -R user:user /home/user/appHistolung/data/outputs


# Install necesary requeriments and dependencies
RUN pip3 install -r requirements.txt

# Copy the entire directory into the container
COPY --chown=user:user aiModel/f_MIL_res34v2_v2_rumc_best_cosine_v3 /home/user/appHistolung/trained_models/MIL/f_MIL_res34v2_v2_rumc_best_cosine_v3


# Default entrypoint
CMD [ "/bin/bash" ]