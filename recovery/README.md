# Recovering a lost Control Node

## Configure Base OS

  * Set Hostname
  * Configure networking, ntp, dns
  * Configure dgx user
  * Configure storage, including docker volumes
  * Generate a new SSH key
  * Restore deepops/dgx-setup files to /home/dgxadmin

## Backup etcd
  * See: https://ystatit.medium.com/backup-and-restore-kubernetes-etcd-on-the-same-control-plane-node-20f4e78803cb
  * NOTE: Must run as root

Prepare etcdctl environment
```
sudo bash
export ETCDCTL_API=3
export ETCDCTL_CACERT=/etc/ssl/etcd/ssl/ca.pem
export ETCDCTL_CERT=/etc/ssl/etcd/ssl/admin-$(uname -n).pem
export ETCDCTL_KEY=/etc/ssl/etcd/ssl/admin-$(uname -n)-key.pem
```

Check member list and Cluster status
```
/usr/local/bin/etcdctl member list

/usr/local/bin/etcdctl endpoint status --write-out=table \
  --endpoints=https://<ETCD1_IP>:2379,https://<ETCD1_IP>:2379,https://<ETCD1_IP>:2379
```

From a working control node as root
```
/usr/local/bin/etcdctl snapshot save snapshotdb.$(date +'%s')
```

To Restore...
  * Stop all kubernetes services excep etcd

```
/usr/local/bin/etcdctl snapshot restore ./<snapshot-file>
```


## Run DGX-Setup
Install the following
```
sudo yum update -y && \
    sudo yum install epel-release -y && \
    sudo yum update -y && \
    sudo yum install ansible git python2-pip python-netaddr
```

Fix PIP
```
sudo pip install --upgrade pip==20.3.4
```

Run setup playbook
./dgx-setup
```
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -v -i ./inventory -l all --ask-become-pass ./cluster-repair.yaml
```

Fix Jinja Issues
#### Playbook issues
If issues with kubeadmin arise, run the following. There is a jinja version issue.
```
sudo yum remove python-jinja2
sudo pip uninstall ansible Jinja2
sudo pip install --upgrade ansible==2.9.5
sudo pip install --upgrade Jinja2==2.11.1
```

## Run Recovery
  * NOTE: Need python-netaddr installed vi YUM

### Manual Removal
Delete Node
```
kubectl delete node <NODE_NAME>
```

Prepare etcdctl environment
```
sudo bash
export ETCDCTL_API=3
export ETCDCTL_CACERT=/etc/ssl/etcd/ssl/ca.pem
export ETCDCTL_CERT=/etc/ssl/etcd/ssl/admin-$(uname -n).pem
export ETCDCTL_KEY=/etc/ssl/etcd/ssl/admin-$(uname -n)-key.pem
```

Delete etcd instance
```
/usr/local/bin/etcdctl member list
/usr/local/bin/etcdctl member remove <MEMBER_ID>
```

Check Status
```
/usr/local/bin/etcdctl member list

/usr/local/bin/etcdctl endpoint status --write-out=table \
  --endpoints=https://<ETCD1_IP>:2379,https://<ETCD1_IP>:2379,https://<ETCD1_IP>:2379
```

### Setup Inventory
  * Copy the inventory to inventory.recover
  * Set the "etcd_member_name=etcd#" for each node under [all]
  * Create [broken_etcd] and [broken_kube-master]
    * Place the broken node under them
  * Move the broken node to the end of the lists - [kube-master] and [etcd]

Example, nvidia-mgmt01 is the broken node
```
[all]
nvidia-mgmt01 ansible_host=10.227.209.171 ip=10.227.209.171 etcd_member_name=etcd1
nvidia-mgmt02 ansible_host=10.227.209.172 ip=10.227.209.172 etcd_member_name=etcd2
nvidia-mgmt03 ansible_host=10.227.209.173 ip=10.227.209.173 etcd_member_name=etcd3
nvidia-node01 ansible_host=10.227.209.181 ip=10.227.209.181
nvidia-node02 ansible_host=10.227.209.182 ip=10.227.209.182

[kube-master]
nvidia-mgmt02
nvidia-mgmt03
nvidia-mgmt01

[etcd]
nvidia-mgmt02
nvidia-mgmt03
nvidia-mgmt01

[broken_etcd]
nvidia-mgmt01

[broken_kube-master]
nvidia-mgmt01
```

### Edit Recovery Playbooks
__IMPORTANT__
  * Since we manually deleted the kube/etcd node, we don't need Kubespray to do it. It will DAMAGE the cluster!
  * Need to comment out these actions in the following file

./deepops/submodules/kubespray/recover-control-plane.yml
```
# - hosts: "{{ groups['etcd'] | first }}"
#   roles:
#     - { role: kubespray-defaults}
#     - { role: recover_control_plane/etcd }

# - hosts: "{{ groups['kube-master'] | first }}"
#   roles:
#     - { role: recover_control_plane/master }
```

### Recover
```
ansible-playbook --ask-become-pass -l etcd,kube-master -e etcd_retries=60 -i ./config/inventory.recover ./submodules/kubespray/recover-control-plane.yml
```

## Post-Recovery

### Check Cluster Status
Check Status
```
kubectl get nodes
```

Prepare etcdctl environment
```
sudo bash
export ETCDCTL_API=3
export ETCDCTL_CACERT=/etc/ssl/etcd/ssl/ca.pem
export ETCDCTL_CERT=/etc/ssl/etcd/ssl/admin-$(uname -n).pem
export ETCDCTL_KEY=/etc/ssl/etcd/ssl/admin-$(uname -n)-key.pem
```


etcd Status
```
/usr/local/bin/etcdctl member list

/usr/local/bin/etcdctl endpoint status --write-out=table \
  --endpoints=https://<ETCD1_IP>:2379,https://<ETCD1_IP>:2379,https://<ETCD1_IP>:2379
```

Install K9s and validate
```
wget https://github.com/derailed/k9s/releases/download/v0.25.18/k9s_Linux_x86_64.tar.gz
tar -xzf k9s_Linux_x86_64.tar.gz
sudo cp ./k9s /usr/local/bin
rm -f ./k9s* ./LICENSE ./README.md
```


### Enable workloads on mgmt nodes
The node will be tainted, need to remove it.
```
kubectl taint node <NODE_NAME> node-role.kubernetes.io/master:NoSchedule-
```

### Validate /etc/hosts on nodes
Redistribute hosts file if needed

  * Note that you may need to recreate these per host initially
  * Once metallb is up-and-running, you can coonfigure it as the VIP
```
```

### Run Firewall CMD
```
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -v -i ./inventory -l <NODE_NAME> --ask-become-pass ./configure-firewall.yaml
```

### Distribute Kubectl
Copy the kubeconfig from node1 to dgx and distribute.

