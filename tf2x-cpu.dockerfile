FROM "ubuntu:latest"
# Needed for string substitution
SHELL ["/bin/bash", "-c"]
RUN apt-get update && apt-get upgrade -y

# See http://bugs.python.org/issue19846
ENV LANG C.UTF-8

# Pick up some TF dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libzmq3-dev \
        pkg-config \
        software-properties-common \
        unzip \
        python3 \
        python3-pip \
        git \
        wget 

RUN python3 -m pip --no-cache-dir install --upgrade \
    pip \
    setuptools
# Some TF tools expect a "python" binary
RUN ln -s $(which python3) /usr/local/bin/python

COPY bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc

RUN python3 -m pip install --upgrade jupyter tensorflow-cpu matplotlib jupyter_http_over_ws ipykernel nbformat numpy opencv-python pandas scipy matplotlib seaborn scikit-learn

RUN jupyter serverextension enable --py jupyter_http_over_ws

RUN mkdir -p /tf && chmod -R a+rwx /tf/
RUN mkdir /.local && chmod a+rwx /.local

WORKDIR /tf

RUN apt-get autoremove -y

EXPOSE 8888

RUN python3 -m ipykernel.kernelspec

CMD ["bash", "-c", "source /etc/bash.bashrc && jupyter notebook --notebook-dir=/tf --ip 0.0.0.0 --no-browser --allow-root"]
