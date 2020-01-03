FROM ubuntu:18.04 AS build

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y \
    autoconf \
    bison \
    build-essential \
    clang \
    cmake \
    curl \
    flex \
    gawk \
    git \
    gperf \
    graphviz \
    gtkwave \
    libboost-program-options-dev \
    libffi-dev \
    libftdi-dev \
    libgmp-dev \
    libreadline-dev \
    mercurial \
    pkg-config \
    python \
    python3 \
    tcl-dev \
    vim \
    wget \
    xdot

# SymbiYosys
WORKDIR /build
RUN git clone https://github.com/cliffordwolf/SymbiYosys.git SymbiYosys
WORKDIR /build/SymbiYosys
RUN make DESTDIR=/install install

# boolector
WORKDIR /build
RUN git clone https://github.com/boolector/boolector
WORKDIR /build/boolector
RUN ./contrib/setup-lingeling.sh
RUN ./contrib/setup-btor2tools.sh
RUN ./configure.sh --prefix /install
RUN cd build && make all install


FROM ubuntu:18.04 AS dev
ENV DEBIAN_FRONTEND noninteractive

COPY --from=towoe/sv2v /usr/bin/sv2v /usr/bin
COPY --from=towoe/yosys /usr/local/ /usr/local/
COPY --from=build /install/ /

RUN apt-get update && apt-get install -y \
    libffi-dev \
    libtcl8.6 \
    python3
CMD ["/bin/bash"]
