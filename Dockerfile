ARG VERSION_CUDA=10.0-cudnn7
ARG VERSION_UBUNTU=18.04

FROM nvidia/cuda:${VERSION_CUDA}-devel-ubuntu${VERSION_UBUNTU} as build

ARG VERSION_FFMPEG=4.3.2
ARG VERSION_LIBTENSORFLOW=1.15.0
ARG DEPENDENCIES="\
  autoconf \
  automake \
  build-essential \
  ca-certificates \
  cmake \
  curl \
  dkms \
  fonts-nanum \
  fonts-nanum-coding \
  fonts-nanum-extra \
  gfortran \
  gir1.2-gtk-3.0 \
  git \
  git-core \
  graphviz \
  htop \
  iputils-ping \
  libasound2-dev \
  libass-dev \
  libatlas-base-dev \
  libavresample-dev \
  libavdevice-dev \
  libboost-dev \
  libboost-filesystem-dev \
  libboost-system-dev \
  libcairo2-dev \
  libcurl3-dev \
  libdc1394-22-dev \
  libeigen3-dev \
  libfaac-dev \
  libfdk-aac-dev \
  libfreetype6-dev \
  libgdal-dev \
  libgeos-dev \
  libgeos++-dev \
  libgflags-dev \
  libgirepository1.0-dev \
  libgnutls28-dev \
  libgomp1 \
  libgoogle-glog-dev \
  libgphoto2-dev \
  libgstreamer-plugins-base1.0-dev \
  libgstreamer1.0-dev \
  libhdf5-dev \
  libhdf5-serial-dev \
  libjpeg-dev \
  liblapack-dev \
  libmp3lame-dev \
  libmpdec2 \
  libnuma-dev \
  libopenblas-dev \
  libopencore-amrnb-dev \
  libopencore-amrwb-dev \
  libopus-dev \
  libpng-dev \
  libportmidi-dev \
  libproj-dev \
  libprotobuf-dev \
  libsdl-dev \
  libsdl-image1.2-dev \
  libsdl-mixer1.2-dev \
  libsdl-ttf2.0-dev \
  libsdl2-dev \
  libsm6 \
  libsmpeg-dev \
  libssl-dev \
  libswscale-dev \
  libtbb-dev \
  libtheora-dev \
  libtiff-dev \
  libtool \
  libunistring-dev \
  libv4l-dev \
  libva-dev \
  libvdpau-dev \
  libvorbis-dev \
  libvpx-dev \
  libxcb-shm0-dev \
  libxcb-xfixes0-dev \
  libxcb1-dev \
  libx264-dev \
  libx265-dev \
  libxine2-dev \
  libxml2-dev \
  libxrender-dev \
  libxslt1-dev \
  libxvidcore-dev \
  libzmq3-dev \
  mercurial \
  mime-support \
  nasm \
  net-tools \
  openssh-client \
  openssh-server \
  pdsh \
  pkg-config \
  proj-bin \
  protobuf-compiler \
  python3.6 \
  python3.6-dev \
  python3.6-gdal \
  subversion \
  texinfo \
  unzip \
  v4l-utils \
  vim \
  wget \
  yasm \
  zip \
  zlib1g-dev \
"

ENV DEBIAN_FRONTEND=noninteractive \
    TERM=xterm

COPY script/ /usr/local/sbin/
COPY codec/nvcodec.tar /tmp/
 
RUN set -o errexit \
 && set -o xtrace \
 && bootstrap-prepare \
 && bootstrap-upgrade \
 && bootstrap-install ${DEPENDENCIES} \
 && build ${VERSION_LIBTENSORFLOW} ${VERSION_FFMPEG} \
 && produce-sr-models ${VERSION_LIBTENSORFLOW} \
 && echo "/usr/local/lib" >> /etc/ld.so.conf \
 && echo "/deps/usr/local/lib" >> /etc/ld.so.conf \
 && tar xf /tmp/nvcodec.tar -C /tmp \
 && mv /tmp/lib/* /usr/local/lib/ \
 && ldconfig
#\
# && cleanup ${DEPENDENCIES}

ENTRYPOINT ["/usr/local/bin/ffmpeg"]


#FROM nvidia/cuda:${VERSION_CUDA}-runtime-ubuntu${VERSION_UBUNTU}

LABEL authors="Vít Novotný <witiko@mail.muni.cz>,Mikuláš Bankovič <456421@mail.muni.cz>,Dirk Lüth <dirk.lueth@gmail.com>, Jungseung Yang <jsyang@lablup.com>" \
      org.label-schema.docker.dockerfile="/Dockerfile" \
      org.label-schema.name="nvidia.ffmpeg"

#ARG DEPENDENCIES="\
#  libgomp1 \
#"
#
#ENV DEBIAN_FRONTEND=noninteractive \
#    TERM=xterm

#COPY script/ /usr/local/sbin/

#COPY --from=build /deps /
#COPY --from=build /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg
#COPY --from=build /usr/local/bin/ffprobe /usr/local/bin/ffprobe
#COPY --from=build /usr/local/share/ffmpeg-tensorflow-models/ /usr/local/share/ffmpeg-tensorflow-models/

#RUN set -o errexit \
# && set -o xtrace \
# && bootstrap-prepare \
# && bootstrap-install ${DEPENDENCIES} \
# && ln -s /usr/local/share/ffmpeg-tensorflow-models/ /models \
# && cleanup

#ENTRYPOINT ["/usr/local/bin/ffmpeg"]
