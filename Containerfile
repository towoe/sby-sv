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

# sv2v
WORKDIR /build
RUN curl -sSL https://get.haskellstack.org/ | sh
RUN git clone https://github.com/zachjs/sv2v.git
WORKDIR /build/sv2v
RUN make

# yosys
WORKDIR /build
RUN git clone https://github.com/YosysHQ/yosys.git yosys
WORKDIR /build/yosys
RUN make config-clang
RUN DESTDIR=/install make install -j$(nproc)

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

# yices 2
WORKDIR /build
RUN git clone https://github.com/SRI-CSL/yices2.git yices2
WORKDIR /build/yices2
RUN autoconf
RUN ./configure --prefix /install
RUN make -j$(nproc)
RUN make install


FROM ubuntu:18.04 AS dev
ENV DEBIAN_FRONTEND noninteractive

COPY --from=build /build/sv2v/bin/sv2v /usr/bin
COPY --from=build /install/ /

RUN apt-get update && apt-get install -y \
    libffi-dev \
    libtcl8.6 \
    make \
    python3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]
