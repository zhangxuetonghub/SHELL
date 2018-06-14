source /etc/kolla/admin-openrc.sh

IP_LIST=( 172.16.150.7 172.16.150.16 )
VIP=172.16.150.252
for i in ${IP_LIST[@]}
do
    openstack port set --allowed-address ip-address=${VIP} $(openstack port list|grep \'$i\'|awk '{print $2}')
done
