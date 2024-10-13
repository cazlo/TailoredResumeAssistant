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

FROM ghcr.io/huggingface/text-generation-inference:latest-rocm-cazlo AS gpu-setup-smokecheck

# todo lame hack, note not needed in the fedora box, wtf
RUN sed -i 's/video:x:44:/video:x:106:ubuntu,root/'  /etc/group && \
    sed -i 's/input:x:106:/input:x:111:/'  /etc/group && \
    sed -i  's/render:x:109:/render:x:235:ubuntu,root/' /etc/group

# capturing random notes and links for later.  not sure TGI is going to be a quick win. \
# first recompiling/rebuilding the image is like 6-8 hrs and must be done on a machine with at least 64GB of RAM (they seem to recommend 96GB!)
# flash-attentions seems to be a big point of contention for the RDNA stuff. it seems like AMD isn't putting effort into making a custom kernel for this, only for the
# M200 super GPUs which I dont want to buy right now.  there are some (small) patches floating around and lots of indications of getting
# other llms to work on gfx1100, but not for TGI. should probably get those working at least somewhat before jumping back into TGI, reducing amount of stuff
# and time in the build loops
# links for later
# - https://rocm.docs.amd.com/projects/radeon/en/latest/index.html (`Flash Attention 2 Forward pass enablement`) disussed for RDNA3
# - https://docs.vllm.ai/en/latest/getting_started/amd-installation.html
# - https://github.com/vllm-project/vllm/blob/main/Dockerfile.rocm#L82-L93 - note when BUILD_FA skipps the flash-attention build entirely for RDNA3
# - both vals for this flag are no go - https://github.com/huggingface/text-generation-inference/blob/0c478846c5002a4053b0349d6557bafb9cedc935/server/text_generation_server/layers/attention/rocm.py#L16
# - https://github.com/ROCm/flash-attention/issues/27 RDNA3 support thread
# - detailed info on getting stable-diffusion + webui working https://github.com/ROCm/flash-attention/issues/27#issuecomment-1876129882
# - https://github.com/vllm-project/vllm/issues/4514 [Bug]: For RDNA3 (navi31; gfx1100) VLLM_USE_TRITON_FLASH_ATTN=0 currently must be forced
#    "With ROCm/triton#596 closed I decided to rebuild build triton-lang/triton and was able to run VLLM_USE_TRITON_FLASH_ATTN=1 on an unmodified vllm 0.4.2 + gfx1100"
# - https://github.com/ROCm/aotriton/issues/16 [Feature]: Memory Efficient Flash Attention for gfx1100 (7900xtx) #16
#    Pytorch nightly out - torch: 2.5.0.dev20240912+rocm6.2 SDP - flash attention works out of the box. No tweaking, special configuration etc.
#    Just enable SDP and use env var: TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1
#    https://github.com/pytorch/pytorch/blob/b361cd01f1025b13f4980f3b22b05d2324636170/aten/src/ATen/native/transformers/cuda/sdp_utils.cpp#L270-L277
# - https://github.com/ROCm/composable_kernel/issues/1434 WMMA / RDNA3+ kernels for backwards fused attention?
