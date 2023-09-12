# debugging
set -x

#stop disp manager
systemctl stop gdm

#unload nvidia drivers
modprobe -r nvidia_uvm
modprobe -r nvidia_drm
modprobe -r nvidia_modeset
modprobe -r nvidia

sleep 6

#load vf
modprobe vfio
modprobe vfio_pci
modprobe vfio_iommu_type1

systemctl restart gdm
