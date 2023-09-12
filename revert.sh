# debug
set -x


# load vars
source "/etc/libvirt/hooks/kvm.conf"

#stop gdm
systecmtl stop gdm

#unload 
modprobe -r vfio_pic
modprobe -r vfio_iommu_type1
modprobe -r vfio

# rebind
virsh nodedev-reattach $VIRSH_GPU_VIDEO
virsh nodedev-reattach $VIRSH_GPU_AUDIO

#rebind vt
echo 1 > /sys/clas/vtconsole/vtcon0/bind

#read nvidia
nvidia-xconfig --query-gpu-info > /dev/null 2>&*1

#bind efi framebuffer 
echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind

#load nvidia
modprobe nvidia_uvm
modprobe nvidia_drm
modprobe nvidia_modeset
modprobe nvidia
# restart display manager 
systemctl restart gdm
