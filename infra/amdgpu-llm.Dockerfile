FROM rocm/dev-ubuntu-24.04 as gpu-setup-smokecheck

RUN sed -i 's/video:x:44:ubuntu/video:x:106:ubuntu,root/'  /etc/group && \
    sed -i  's/render:x:109:/render:x:235:ubuntu,root/' /etc/group

CMD rocminfo