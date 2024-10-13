FROM rocm/pytorch:latest-base AS not-currently-used
# official docs are pointing here but this is using ubuntu 20.04 which I'm not jazzed about. leaving this here for future pathfinding
# see also https://rocm.docs.amd.com/projects/install-on-linux/en/develop/install/3rd-party/pytorch-install.html

FROM rocm/pytorch:rocm6.2.3_ubuntu22.04_py3.10_pytorch_release_2.3.0 AS not-currently-used-2

#RUN apt update && apt upgrade -y todo caching or cleanup
USER root
# todo lame hack
RUN sed -i 's/video:x:44:/video:x:106:jenkins,root/'  /etc/group && \
    sed -i 's/input:x:106:/input:x:111:/'  /etc/group && \
    sed -i  's/render:x:109:/render:x:235:jenkins,root/' /etc/group

#USER ubuntu
CMD rocminfo

FROM ghcr.io/huggingface/text-generation-inference:latest-rocm AS gpu-setup-smokecheck

# todo lame hack
RUN sed -i 's/video:x:44:/video:x:106:ubuntu,root/'  /etc/group && \
    sed -i 's/input:x:106:/input:x:111:/'  /etc/group && \
    sed -i  's/render:x:109:/render:x:235:ubuntu,root/' /etc/group