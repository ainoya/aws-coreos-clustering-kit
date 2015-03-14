#!/bin/sh -xe

ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

mkdir -p /opt/latest/bin

echo "Updating to latest docker.."
wget -q https://get.docker.com/builds/Linux/x86_64/docker-latest -O /opt/latest/bin/docker
chmod +x /opt/latest/bin/docker
cat << EOF > /etc/systemd/system/docker.service
.include /usr/lib/systemd/system/docker.service

[Service]
ExecStart=
ExecStart=/opt/latest/bin/docker -d --insecure-registry 0.0.0.0/0
EOF


echo "Updating to latest etcd.."

ETCD_VER="v2.0.0"
ETCD_NAME="etcd-${ETCD_VER}-linux-amd64"

cd /tmp
curl -L  https://github.com/coreos/etcd/releases/download/${ETCD_VER}/${ETCD_NAME}.tar.gz -o ${ETCD_NAME}.tar.gz
tar xzvf ${ETCD_NAME}.tar.gz

cd ${ETCD_NAME}
mv etcd etcdctl etcd-migrate /opt/latest/bin/
chmod +x /opt/latest/bin/{etcd,etcdctl,etcd-migrate}

cd /tmp && rm -rf ${ETCD_NAME}*

cat << EOF > /etc/systemd/system/etcd.service
.include /usr/lib/systemd/system/etcd.service
[Service]
ExecStart=
ExecStart=/opt/latest/bin/etcd
EOF

rm /home/core/.bashrc
cat /usr/share/skel/.bashrc > /home/core/.bashrc
echo 'export PATH=/opt/latest/bin:$PATH' >> /home/core/.bashrc

