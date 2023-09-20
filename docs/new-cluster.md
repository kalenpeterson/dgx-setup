# Creating a new cluster setup

## 1) Clone Deeopops
https://github.com/NVIDIA/deepops/blob/master/docs/dgx-pod.md
```
git clone --recurse-submodules --branch 20.10 https://github.com/NVIDIA/deepops.git
cd deepops
git submodule update
```

## 2) Run Deepops Setup
```
cd deepops
./scripts/setup.sh
```

## 3) Clone DGX-Setup
```
git clone https://github.com/kalenpeterson/dgx-setup.git
```


## 4) Configure inventory file
Configure all params

## 4.1) Create User/Sudoers on New Node
```
sudo bash
useradd -b /home -u 1001 -G sudo -m -U -s /bin/bash dgx
passwd dgx
echo 'dgx ALL=(ALL) NOPASSWD:ALL' >/etc/sudoers.d/dgx
```
## 5) Run cluster-prep
```
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -v -i ./inventory -l all ./cluster-prep.yaml
```

## 6) Run Upgrades on dgx nodes
https://docs.nvidia.com/dgx/pdf/DGX-OS-server-4.6-relnotes-update-guide.pdf
Do we want to upgrade the driver? Look at 450 upgrade. We will need to add the repo.
```
sudo apt update
sudo apt full-upgrade -s
sudo apt full-upgrade
```