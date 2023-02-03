# Add a Cluster node

Adding a Kube Node


## 1. Run cluster setup
```
ansible-playbook -i ./inventory -l lambda ./cluster-setup.yaml
```

## 2. Edit deepops Inventory
Add new nodes to All with ip and ansible_host. Add names to kube-nodes

Add to all:vars
```
dploy_container_engine=False
download_run_once=True
```

## 3. Run Deepops expand
```
ansible-playbook -i ./config/inventory -l k8s-cluster ./submodules/kubespray/scale.yml
```

If sucessfull, check the node status with
```
kubectl get nodes
```

### Issues
There may be some issues running the scale.yml playbook. Here are some common issues and resolutions.

#### Jinga Package version
Kubespray requires at least jinja 2.11. If you hit an error with setting up kubeadm do the following. Note this will uninstall the openshift client as well, so we are reinstalling it.
```
sudo yum remove python-jinja2
sudo pip uninstall ansible Jinja2
sudo pip install --upgrade ansible==2.9.5
sudo pip install --upgrade Jinja2==2.11.1
sudo pip install --upgrade setuptools
sudo pip install --upgrade openshift==0.11.2
```
See the following
https://github.com/kubernetes-sigs/kubespray/issues/5958kub


## 4. Label Nodes
Label each node as a compute node.

```
kubectl label node NODE_NAME node-role.kubernetes.io/node=
```

Apply Custom node-type labels.
```
kubectl label node NODE_NAME system_type=lambda
```

## 5. Validation
These are some steps to validate the cluster is working

### Check System/Monitoring Pods
Validate that the system and monitoring pods are running on the new node

Run this for each new node to ensure all pods are running and not restarting
```
kubectl get pods -A -o wide |grep NODE_NAME
```

### Check to make sure NFD annotations are working
Check to make sure we can see the Nvidia GPUs on each node
```
kubectl describe node NODE_NAME
```

