# 官方下载的openstack的centos镜像，默认不允许使用密码认证登录，只允许用户centos密钥登录，通过开机脚本更改使其允许root密码认证登录，方便使用ansible
#!/bin/bash
a=$( cat /root/s.t )

if [ $a == 0 ]; then
        rm -rf  /etc/ssh/sshd_config && mv /etc/ssh/sshd_config.back /etc/ssh/sshd_config && echo 1 > /root/s.t;
        /bin/systemctl restart sshd;
fi
