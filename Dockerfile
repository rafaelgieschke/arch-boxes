FROM archlinux:latest
RUN pacman -Syu --needed --noconfirm xorriso qemu-headless
WORKDIR /build
COPY . .
RUN ./build-host.sh
