## Single GPU Laptop passthrough guide.
This guide will help those with dual monitor setup as we will be able to use the second monitor for both linux and virtual machine vm without the need for rebooting. But this will also be as useful for desktop single GPU users as well.<br>
**Also we will take reference from the archLinux wiki** --> https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF
> This guide will be beginner friendly.
> > I'll be explaining all the steps taken and will also quote the failures i faced in that step
***
## System Description
My system description is visible in below screenshot. <br />
Laptop:- Legion 5i <br />
1. OS:- Arch Linux *(I use Arch btw!)* <br>
2. Kernel:- 6.1.52-1-lts (long term support)
3. Cpu:- Intel i5-10500H <br />
4. Gpu:- Nvidia rtx 3050 **--> This is the gpu we will be passing to the win10 VM**
![ss](https://github.com/BeroBrine/kvmGPU/assets/74451882/d22f9bea-b155-4cb7-b0db-e246089f88f3)
***
## 1) Prerequisites
1. Your CPU must support hardware virtualisation. Also turn on virtualisaton technology from the bios.
2. Your motherboard must support IOMMU
3. Guest ROM(in our case win10) must support UEFI. (win10 does support this).

## 2) Turn on intel_iommu / amd_iommu <br>
**IMP:- WE CAN SKIP THE NEXT STEPS UPTO INSTALLING VFIO MODULES BY INSTALLING gpu-passthrough-manager** <br> **link -->** [Github link](https://github.com/uwzis/GPU-Passthrough-Manager) <br>
***
We need to turn on IOMMU Grouping. Using IOMMU opens to features like PCI passthrough and memory protection from faulty or malicious devices. <br>
1. First we need to edit grub (if you are using other boot-manager you need to find the equivalent as i use grub only)
2. `$ nano /etc/default/grub` <-- *The $ means you need to run this as sudo and # means you can run the command as user . also i'll be using nano text editor because it is beginner friendly.* <br>
> If you do not have nano run `$ pacman -Sy nano `.
> 
3. In the line GRUB_CMDLINE_LINUX_DEFAULT add `intel_iommu=on` for intel users or `amd_iommu=on` for amd users.
![Screenshot from 2023-09-11 22-56-12](https://github.com/BeroBrine/kvmGPU/assets/74451882/0bb309c2-f764-4af6-ba60-ca2fae7fd874) <br>
You can also append the `iommu=pt` parameter. This will prevent Linux from touching devices which cannot be passed through.
4. Reboot after this. Open up terminal and run `$ dmesg | grep -i -e DMAR -e IOMMU`. We will find something like
  "Adding to iommu group ##". If you can't find this retry the above steps.
5. Run the script provided above in terminal by executing `./iommu.sh` to check which PCI devices are mapped to which IOMMU groups. <br>
Example ouput. <br>
  `IOMMU Group 1:
	00:01.0 PCI bridge: Intel Corporation Xeon E3-1200 v2/3rd Gen Core processor PCI Express Root Port [8086:0151] (rev 09)`
```diff
- WARNING:- If you find anything other than your GPU and it's subsequent audio device and a PCI component. <br>
- This guide won't work for you as we need the GPU components to be totally seperated. For me my GPU was in iommu group 2 and it looked like this.
```
![Screenshot from 2023-09-11 23-18-12](https://github.com/BeroBrine/kvmGPU/assets/74451882/eb066545-d50f-469f-a747-59f9ab42bae1)






