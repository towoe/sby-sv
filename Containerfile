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

# yosys
WORKDIR /build
RUN git clone https://github.com/YosysHQ/yosys.git yosys
WORKDIR /build/yosys
RUN DESTDIR=/install make install -j$(nproc)

# Z3
WORKDIR /build
RUN git clone https://github.com/Z3Prover/z3.git z3
WORKDIR /build/z3
RUN python scripts/mk_make.py
WORKDIR /build/z3/build
RUN make -j$(nproc)
RUN DESTDIR=/install make install

# SymbiYosys
WORKDIR /build
RUN git clone https://github.com/cliffordwolf/SymbiYosys.git SymbiYosys
WORKDIR /build/SymbiYosys
RUN make DESTDIR=/install install

# boolector
WORKDIR /build
RUN wget http://fmv.jku.at/boolector/boolector-2.4.1-with-lingeling-bbc.tar.bz2 && \
         tar xvjf boolector-2.4.1-with-lingeling-bbc.tar.bz2
WORKDIR /build/boolector-2.4.1-with-lingeling-bbc
RUN make
RUN cp boolector/bin/boolector /install/usr/local/bin/boolector

WORKDIR /build
RUN curl -sSL https://get.haskellstack.org/ | sh
RUN git clone https://github.com/zachjs/sv2v.git
WORKDIR /build/sv2v
RUN make

FROM ubuntu:18.04 AS dev
ENV DEBIAN_FRONTEND noninteractive
COPY --from=build /install/ /
COPY --from=build /build/sv2v/bin/sv2v /usr/bin/
RUN apt-get update && apt-get install -y \
    build-essential \
    libffi-dev \
    libtcl8.6 \
    python3
WORKDIR /project
CMD ["/bin/bash"]
