FROM archlinux

EXPOSE 8188

ENV PACMAN_FLAGS="--noconfirm --needed" VISUAL=nvim EDITOR=nvim

RUN pacman -Syu $PACMAN_FLAGS

RUN pacman -Syu git neovim locate sudo libgl base-devel less wget openmpi plocate $PACMAN_FLAGS

RUN groupadd sudo

RUN useradd -rm -d /home/dev -s /bin/bash -g root -G sudo -u 1001 -p "$(openssl passwd -1 password)" dev

# Gives the user to have root permissions:
RUN usermod -aG sudo dev
RUN echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

USER dev
WORKDIR /home/dev

# Install Python 3.12
RUN wget https://www.python.org/ftp/python/3.12.8/Python-3.12.8.tgz
RUN echo "304473cf367fa65e450edf4b06b55fcc Python-3.12.8.tgz" | md5sum -c - \
    && echo "Checksum is valid" || ( echo "Checksum does not match!" && exit 1 )
RUN tar -xf ./Python-3.12.8.tgz \
    && cd Python-3.12.8 \
    && ./configure --enable-shared \
    && make -j $(nproc)
RUN cd Python-3.12.8 \
    && sudo make install \
    && sudo ln -s /usr/local/bin/python3 /usr/local/bin/python

RUN echo "/usr/local/lib" | sudo tee -a /etc/ld.so.conf.d/python3.12.conf \
    && sudo ldconfig

RUN sudo pip3 install tensorrt_llm

#CMD ["bash", "-c", "source /home/dev/ComfyUI/comfyui/bin/activate && python -u main.py --port 8188 --listen"]
CMD ["bash"]
