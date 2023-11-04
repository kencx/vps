#!/usr/bin/env bash

set -e

mkdir -pv /mnt/alpine
cd /mnt/alpine

[ -z "${TAR_URL}" ] && exit 2
ROOTFS_ARCHIVE="${TAR_URL##*/}"

# download archive
curl -so "$ROOTFS_ARCHIVE" "$TAR_URL"
curl -so "$ROOTFS_ARCHIVE.sha256" "$TAR_URL.sha256"

# checksum
sha256sum -c "$ROOTFS_ARCHIVE.sha256"

# extract archive
tar -zxf "$ROOTFS_ARCHIVE"

# prepare chroot
cp -v --dereference /etc/resolv.conf etc/resolv.conf
mount -v -t proc proc proc
mount -v --rbind /dev dev
mount -v --make-rslave dev
mount -v --rbind /sys sys
mount -v --make-rslave sys
mount -v --rbind /tmp tmp

# change root default shell to `sh`. bash is not available in alpine
usermod -s /bin/sh root

# setup host sshd to chroot in alpine
sed -i 's/^#\?\(ChrootDirectory\s*\)\S*$/\1\/mnt\/alpine/' \
    /etc/ssh/sshd_config

# change sftp subsystem to `/usr/lib/sftp-server` on host sshd config
sed -i 's/^\(Subsystem\s*sftp\s*\)\S*$/\1\/usr\/lib\/sftp-server/' \
    /etc/ssh/sshd_config

# add sftp-server to the same path in alpine
ln -s "/usr/lib/openssh/sftp-server" ./usr/lib/sftp-server

# install install requirements in alpine
chroot . /bin/sh <<-EOF
	apk add \
	  alpine-conf         `# setup-alpine utilities` \
	  openssh             `# scp chroot bin        ` \
	  openssh-sftp-server `# sftp-server chroot bin`
EOF

# restart ssh and kill all connections
# necessary to ensure next ssh connection will be on chrooted alpine
systemctl restart sshd
