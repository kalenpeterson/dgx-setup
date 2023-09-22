# DGX-Lambda Node Setup
This Document details the procedure to add prepare DGX/Lambda nodes to be added to a cluster.


## Related Repos
These are other Repos related to this project that contain their own documentation and tooling.
| Git Repository                                                    | Description                                           |
| ----------------------------------------------------------------- | ----------------------------------------------------- |
| [kube-slurm](https://github.com/kalenpeterson/kube-slurm)         | Tools for integrating Slurm and Kubernetes            |
| [dgx-chargeback](https://github.com/kalenpeterson/dgx-chargeback) | Tools to manage GPU Chargeback of kube-slurm clusters |


## Document Index
| Document                             | Description                                                | Version Info               |
| ------------------------------------ | ---------------------------------------------------------- | -------------------------- |
| [New Cluster](docs/new-cluster.md)   | Guide to deploying a new Kube Cluster                      | Kalen Peterson, Dec 2020   |
| [Add Node](docs/add-node.md)         | Guide to adding DGX or Lambda nodes to the Cluster         | Kalen Peterson, June 2023  |
| [Repair Cluster](recovery/README.md) | Guide to repair/re-add a broken Master node in the cluster | Kalen Peterson, April 2022 |


## Tool Index
| Tool                                                               | Description                                                     | Version Info               |
| ------------------------------------------------------------------ | --------------------------------------------------------------- | -------------------------- |
| [cluster-setup.yaml](cluster-setup.yaml)                           | Ansible Playbook to configure base cluseter nodes (master/node) | Kalen Peterson, June 2023  |
| [configure-firewall.yaml](configure-firewall.yaml)                 | Ansible playbook to configure firewall on master nodes          | Kalen Peterson, April 2021 |
| [renew-cluster-certs.yaml](renew-cluster-certs.yaml)               | Ansible playbook to renew Kubernetes cluster certificates       | Kalen Peterson, April 2021 |
| [setup-kubectl.yaml](setup-kubectl.yaml)                           | Ansible playbook to configure kubetl and distribure kubeconfig  | Kalen Peterson, April 2021 |
| [renew-cluster-certs.yaml](renew-cluster-certs.yaml)               | Ansible playbook to renew Kubernetes cluster certificates       | Kalen Peterson, April 2021 |
| [restart_cluster_services.sh](scripts/restart_cluster_services.sh) | Shell script to restart all Kube/Slurm services                 | Kalen Peterson, June 2023  |
| [podman_reset.sh](scripts/podman_reset.sh)                         | Shell script to Setup/Reset a User's Podman configuration       | Kalen Peterson, April 2022 |
| [cluster-repair.yaml](recovery/cluster-repair.yaml)                | Ansible playbook to repair/re-add broken master nodes           | Kalen Peterson, April 2022 |


## References
| URL                               | Description                                                |
| --------------------------------- | ---------------------------------------------------------- |
| https://github.com/NVIDIA/deepops | Nvidia deepops project, source for developing this cluster |

