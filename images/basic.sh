#!/bin/bash
# shellcheck disable=SC2034,SC2154
IMAGE_NAME="Arch-Linux-x86_64-basic-${build_version}.qcow2"
# It is meant for local usage so the disk should be "big enough".
DISK_SIZE="40G"
PACKAGES=(firefox xorg-server xorg-xinit xterm)
SERVICES=()

function pre() {
  local NEWUSER="arch"
  arch-chroot "${MOUNT}" /usr/bin/useradd -m -U "${NEWUSER}"
  echo -e "${NEWUSER}\n${NEWUSER}" | arch-chroot "${MOUNT}" /usr/bin/passwd "${NEWUSER}"
  echo "${NEWUSER} ALL=(ALL) NOPASSWD: ALL" >"${MOUNT}/etc/sudoers.d/${NEWUSER}"

  cat <<EOF >"${MOUNT}/etc/systemd/network/80-dhcp.network"
[Match]
Name=eth0

[Network]
DHCP=ipv4
EOF

  cat <<EOF >"${MOUNT}/etc/systemd/system/x.service"
[Unit]
Wants=graphical.target
Before=graphical.target

[Service]
ExecStartPre=modprobe bochs
ExecStart=startx

[Install]
WantedBy=graphical.target
EOF

  arch-chroot "${MOUNT}" /usr/bin/systemctl enable x
  sed -i '$ifirefox &' "${MOUNT}/etc/X11/xinit/xinitrc"
}

function post() {
  qemu-img convert -c -f raw -O qcow2 "${1}" "${2}"
  rm "${1}"
}
