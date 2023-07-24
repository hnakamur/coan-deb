FROM ubuntu:jammy
ARG UBUNTU_REL_NAME=jammy
ARG NFPM_VER=2.32.0

# install curl
RUN apt-get update
RUN apt-get -y install curl ca-certificates g++ make dpkg-dev lintian

# install nfpm
RUN mkdir -p /work
WORKDIR /work
RUN curl -sSLO https://github.com/goreleaser/nfpm/releases/download/v${NFPM_VER}/nfpm_${NFPM_VER}_amd64.deb
RUN dpkg -i nfpm_${NFPM_VER}_amd64.deb

# download pg_statsinfo source tarball
RUN curl -sSLO https://github.com/linxiaohui/coan/archive/refs/heads/master.tar.gz
RUN tar zxf master.tar.gz

WORKDIR /work/coan-master

# build and install
RUN CXXFLAGS=-std=c++11 ./configure --prefix=/usr
RUN make -j V=1
RUN make install DESTDIR=/work/install/
RUN install LICENSE.BSD /work/install/
RUN gzip -cd /work/install/usr/share/man/man1/coan.1.1 | gzip -9 > /work/install/usr/share/man/man1/coan.1.gz
RUN strip --strip-unneeded --remove-section=.comment --remove-section=.note \
      /work/install/usr/bin/coan

COPY debian/control /work/coan-master/debian/
RUN dpkg-shlibdeps -Tsubstvars /work/install/usr/bin/coan
COPY depends.awk /work/coan-master/

# # build deb package
COPY changelog.yaml nfpm.yaml /work/install/
RUN cat substvars | sed 's/^shlibs:Depends=//' | awk -F ', ' -f depends.awk >> /work/install/nfpm.yaml
WORKDIR /work/install
RUN nfpm package -p deb

RUN lintian *.deb
