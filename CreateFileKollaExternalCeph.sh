#!/bin/bash

[ ! -d /etc/ceph ] && echo "please prepare a ceph cluster first, using ceph-deploy with scripts"
cd /etc/ceph

# keyrings
KEYG="ceph.client.glance.keyring"
KEYC="ceph.client.cinder.keyring"
KEYCB="ceph.client.cinder-backup.keyring"
KEYN="ceph.client.nova.keyring"

# path
CC="/etc/ceph/ceph.conf"
KOLLA_CONF="/etc/kolla/config"
CONF_G="${KOLLA_CONF}/glance"
CONF_C="${KOLLA_CONF}/cinder/cinder-volume"
CONF_CB="${KOLLA_CONF}/cinder/cinder-backup"
CONF_N="${KOLLA_CONF}/nova"


# ===Generate Authorization===
#   1.glance
ceph auth get-or-create client.glance mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=images ' | tee ${KEYG}

#   2.cinder
ceph auth get-or-create client.cinder mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=volumes, allow rwx pool=vms, allow rx pool=images ' | tee ${KEYC}

#   3.cinder-backup
ceph auth get-or-create client.cinder-backup mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=backups' | tee ${KEYCB}

#   4.nova
ceph auth get-or-create client.nova mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=volumes, allow rwx pool=vms, allow rx pool=images ' | tee ${KEYN}

# scp
# init dirs
[ ! -d ${CONF_G} ] && mkdir -p ${CONF_G}
[ ! -d ${CONF_C} ] && mkdir -p ${CONF_C}
[ ! -d ${CONF_CB} ] && mkdir -p ${CONF_CB}
[ ! -d ${CONF_N} ] && mkdir -p ${CONF_N}



# ===MakeConfig===
#   1.glance
cp ${CC} ${CONF_G}/
cp ${KEYG} ${CONF_G}/
touch ${CONF_G}/glance-api.conf
cat > ${CONF_G}/glance-api.conf << EOF
[DEFAULT]
show_image_direct_url = True

[glance_store]
stores = rbd
default_store = rbd
rbd_store_pool = images
rbd_store_user = glance
rbd_store_ceph_conf = /etc/ceph/ceph.conf
EOF

#   2.cinder-volume
cp ${CC} ${CONF_C}/
cp ${KEYC} ${CONF_C}/
touch ${CONF_C}.conf
cat > ${CONF_C}.conf << EOF
[DEFAULT]
enabled_backends=rbd-1

[rbd-1]
rbd_ceph_conf=/etc/ceph/ceph.conf
rbd_user=cinder
backend_host=rbd:volumes
rbd_pool=volumes
volume_backend_name=rbd-1
volume_driver=cinder.volume.drivers.rbd.RBDDriver
rbd_secret_uuid = {{ cinder_rbd_secret_uuid }}
EOF

#   3.cinder-backup
cp ${CC} ${CONF_CB}/
cp ${KEYC} ${CONF_CB}/
cp ${KEYCB} ${CONF_CB}/
touch ${CONF_CB}.conf
cat > ${CONF_CB}.conf << EOF
[DEFAULT]
backup_ceph_conf=/etc/ceph/ceph.conf
backup_ceph_user=cinder
backup_ceph_chunk_size = 134217728
backup_ceph_pool=backups
backup_driver = cinder.backup.drivers.ceph
backup_ceph_stripe_unit = 0
backup_ceph_stripe_count = 0
restore_discard_excess_bytes = true
EOF

#   4.nova
cp ${CC} ${CONF_N}/
cp ${KEYC} ${CONF_N}/
cp ${KEYN} ${CONF_N}/
touch ${CONF_N}/nova-compute.conf
cat > ${CONF_N}/nova-compute.conf << EOF
[libvirt]
images_rbd_pool=vms
images_type=rbd
images_rbd_ceph_conf=/etc/ceph/ceph.conf
rbd_user=nova
EOF
