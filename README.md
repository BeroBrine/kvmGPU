## Single GPU Laptop passthrough guide.
This guide will help those with dual monitor setup as we will be able to use the second monitor for both linux and virtual machine vm without the need for rebooting. But this will also be as useful for single monitor users as well.<br>
***
We will also setup core isolation as well as virtio drivers in this guide to make the performance as bare metal as possible. <br>
For those of you who don't know what cpu isolation and virtio is read below. <br>
> When we boot up a virtual machine and pass some CPUs(cores or threads) to it. Linux as well as the Virtual Machine both share the same resource pools. This increases latency as well as causes stuttering in games. Core Isolation ensures that Linux doesn't use the Cores that are being used by the Virtual Machine. As i have a 6 core CPU i'll be passing 5 cores to the VM and 1 core will be kept for the host i.e Linux.
>
> Also virtio drivers are specially designed for virtualisation so in this guide i''ll be showing how to set them up too.
> 
**Also we will take reference from the archLinux wiki** --> https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF
> This guide will be beginner friendly.
> > I'll be explaining all the steps taken and will also quote the failures i faced in that step
>
***
## System Description
My system description is visible in below screenshot. <br>
1. Laptop:- Legion 5i
2. OS:- Arch Linux *(I use Arch btw!)*
3. Kernel:- 6.1.52-1-lts (long term support)
4. Cpu:- Intel i5-10500H 
5. Gpu:- Nvidia rtx 3050 **--> This is the gpu we will be passing to the win10 VM** <br>
![ss](/screenshots/neofetch.png) <br>
***
## 1) Prerequisites
1. Your CPU must support hardware virtualisation. Also turn on virtualisaton technology from the bios.
2. Your motherboard must support IOMMU.
3. Nvidia card must use nvidia kernel module i.e nvidia drivers.
4. Guest ROM(in our case win10) must support UEFI. (win10 does support this).]
5. An extra Pair of Keyboard mouse to Pass into the VM.

## 2) Turn on intel_iommu / amd_iommu <br>
We need to turn on IOMMU Grouping. Using IOMMU opens to features like PCI passthrough and memory protection from faulty or malicious devices. <br>
1. First we need to edit grub (if you are using other boot-manager you need to find the equivalent as i use grub only)
2. `$ nano /etc/default/grub` <-- *The $ means you need to run this as sudo and # means you can run the command as user . also i'll be using nano text editor because it is beginner friendly.* <br>
> If you do not have nano run `$ pacman -Sy nano `. (pacman is the package manager for arch. use your distro packkage manger if on another distro than arch.)
> 
3. In the line GRUB_CMDLINE_LINUX_DEFAULT add `intel_iommu=on` for intel users or `amd_iommu=on` for amd users. <br>
![Screenshot from 2023-09-11 22-56-12](/screenshots/grub.png) <br>
You can also append the `iommu=pt` parameter. This will prevent Linux from touching devices which cannot be passed through.
4. Reboot after this. Open up terminal and run `$ dmesg | grep -i -e DMAR -e IOMMU`. We will find something like
  "Adding to iommu group ##". If you can't find this retry the above steps.
5. Run the script provided above in terminal by executing `./iommu.sh` to check which PCI devices are mapped to which IOMMU groups. <br>
Example ouput. <br>
  `IOMMU Group 1:
	00:01.0 PCI bridge: Intel Corporation Xeon E3-1200 v2/3rd Gen Core processor PCI Express Root Port [8086:0151] (rev 09)`
```diff
- WARNING:- If you find anything other than your GPU and it's subsequent audio device and a PCI component. <br>
- This guide won't work for you as we need the GPU components to be totally seperated.
- You will need to perform ACS override patch which won't be covered in this guide. 
- For me my GPU was in iommu group 2 and it looked like this.
```
![Screenshot from 2023-09-11 23-18-12](/screenshots/iommu.png)<br>
## 3) Installing the Virtual Machine Packages
Now we need to install the Virtual Machine Manager.
1. Install these packages
`qemu-desktop libvirt edk2-ovmf virt-manager dnsmasq`
2. We need to enable and start required services `libvirtd.service` and `virtlogd.socket`
3. Activate the default libvirt network.
`virsh net-autostart default`
`virsh net-start default`
## 4) Installing win10.
1. Open up virtual machine manager from app tray.
2. Click on the Create A New Virtual Machine Button.
3. Choose Local Install Media(ISO image or CDROM) option.
4. Browse to the win10.iso that you have downloaded from internet.
5. IMP:- uncheck the automatically detect from the installation media / source as virt-manger will detect it as win11
6. Change the win11 to win10 and also click on the (win10) option from the drop down list and click next *// Clicking on the win10 from dropdown list won't make any visible effect. Just click on it and click next* <br>
![Screenshot from 2023-09-11 23-40-17](/screenshots/media.png) <br>
7. Choose how much memory you want to pass. Keep atleast 3GB of RAM for Linux to avoid any unwanted behaviour. Also select the number of CPU that you want to share. <br>
![Screenshot from 2023-09-11 23-50-18](/screenshots/memory.png) <br>
8. Click on forward and choose how much space you want to allocate to the Virtual Machine. I have allocated 250GB. There will be 2 options qcow2 or raw. Raw will pass the size of the disk as a whole. Also if you want to pass a disk run `lsblk` and note the path of the disk you want to pass and just paste the path in the "Select or create custom storage." and the disk will be passed through. <br>
Beware as you will not be able to use the disk in linux properly as NTFS has it's own quirks inside linux so just leave the disk alone and don't mount it to linux.
## 4) Customize Configuration Before Install. (IMPORTANT SECTION) (installing win10 contd..)
1. Click on the "Customize configuration before install" <-- Imp as you won't be able to customise the install after this screen
2. In the Overview Section , select Firmware and Choose "UEFI x86_64: /usr/share/edk2/x64/OVMF_CODE.fd" *DO NOT choose secboot ones* <br>
![Screenshot from 2023-09-12 00-01-48](/screenshots/uefi.png) <br>
3. In CPUs section. Click on Topology and click on Manually set CPU topology and set sockets to 1 and core and threads accordingly (i have passed 10 CPUs so i'll choose 5 cores and 2 Threads to a total of 10 CPUs) <br>
![Screenshot from 2023-09-12 00-04-31](/screenshots/topology.png) <br>
4. Go to SATA Disk 1 and change the bus type to VirtIO. Also you need to download the [VirtIO drivers](https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md). Download the stable virtio-win iso.
5. Click on Add Hardware . Go onto Storage and add the virtioo.iso as CDROM device.
6. Go to Boot Options and select SATA CDROM 1 and place it on top of VirtIO Disk 1. *This is important as virt manager doesn't automatticaly perform this and you won't be able to boot into the installtion if this step is missed. <br>
![Screenshot from 2023-09-12 00-14-21](/screenshots/bootorder.png) <br>
7. Click on the Add Hardware and onto USB host device and add the extra keyboard and mouse to the Virtual Machine.
8. We will not pass the graphics card now , it'll be performed when we will finish setting up win10 . Continue with the installation. <br>
You should be able to boot into the window install.
9. While selecting the disks we will encounter that there is not drive listed. This is because we have chosen the disk driver to be VirtIO instead of SATA. <br>
![Screenshot from 2023-09-12 09-52-07](/screenshots/disk.png) <br>
10. We will need to install drivers for VirtIO. Click on the Load driver option below refresh. Click on the Browse option and select the VirtIO iso we had passed through before.
11. In the drop down list we will find viostor. click on that and go to w10 and select amd64 for x64 architecture.
12. The driver should be listed by the name "Red Hat VirtIO SCSI controller". Install this driver.
13. We can continue the rest of the installation normally.
14. Setup windows until we boot into Home Screen.
## 5) Prepping our GPU for Pass Through.
1. Until now we did not pass through our gpu. Now we will setup hooks so that when we turn on our virtual machine our GPU card gets attached to virtual machine and when we turn off the card gets attached to linux so we will be able to use the card for linux as well as virtual machines.
2. First we need to install hooks for qemu. Hooks enable us to execute scripts  when we turn on or off our virtual machine.
[**Link for hooks reference**](https://passthroughpo.st/simple-per-vm-libvirt-hooks-with-the-vfio-tools-hook-helper/)
3. First make this directory. <br>
`$ mkdir -p /etc/libvirt/hooks`
4. Install hook helper and make it executable. <br>
   `sudo wget 'https://raw.githubusercontent.com/PassthroughPOST/VFIO-Tools/master/libvirt_hooks/qemu' \
     -O /etc/libvirt/hooks/qemu`<br>
     `sudo chmod +x /etc/libvirt/hooks/qemu`
5. Now download the `start.sh` script from my repo. Make a directory <br>
    `mkdir -p /etc/libvirt/hooks/qemu.d/win10/prepare/begin` **<-- the *win10* part of the directory must be the same as our virtual machine name. in our case that's win10 but if you have named your vm anything else substitute win10 appropriately**.
6. Move the `start.sh` script into the above directory. <br>
`$ mv start.sh /etc/lbvirt/hooks/qemu.d/win10/prepare/begin/`
7. Download the `revert.sh` script and move the script into the following directory. <br>
`$ mkdir -p /etc/libvirt/hooks/qemu.d/win10/release/end/` <br>
`$ mv revert.sh /etc/libvirt/hooks/qemu.d/win10/release/end/`
> You may need to make the script executable and owned by root. Do this by running `sudo chmod +x $SCRIPT_NAME`
> also the script assumes that you are using gnome desktop manager. if you are using another desktop manager change the systemctl stop/restart gdm appropriately.
> 
9. Now we have the scripts installed and ready to go.
10. Now go into the virt-manager and open you vm and click on the *light bulb* icon and click on Add Hardware. <br>
    Click on PCI Host Device and add your GPU card and it's subsequent device. 
![Screenshot from 2023-09-12 10-46-18](/screenshots/gpu.png).
**NOTE:- the next step will restart your desktop manager so you'll lose unsaved work on open applications. Save work before proceeding.**
12. Now when you start up the virtual machine your desktop manager will stop and when it will restart only laptop screen will display linux output and your other screen will display the virtual machine.<br> **<-- This step causes a lot of problems. If you do not get this on the first try or if your virtual machine crashes a lot just try again. I had to install around 20-25  with just trial and error adding and deleting things in script and got a script which was consistent for me. You may also try to change config and test upon yourr system -->** <br>
13. If you successfully get upto this point. Install the drivers appropriate for your card and it should install without any problems.<br>
![photo_6053123811320116399_y](/screenshots/photo.jpg) <br>
**<-- In my case , after installing the drivers the screen went black. If this is the same case with you delete the vm but do not delete it's assosciated storage (proceed carefully as virt-manager defaults to deleting the assosciated storage). Click on create a new virtual machine but this time select import existing disk image and repeat the steps of adding GPU and subsequent hardware and install again and it should boot correctly. Remember to name you vm as win10 as hooks won't work if the name is different -->**
14. Open Up your task manager and you should be able to see your card listed. <br>
![photo_6053123811320116409_m](/screenshots/deviceman.jpg) <br>
![photo_6053123811320116408_y](/screenshots/taskmanager.jpg) <br>
15. Now , if you turn off your VM , the desktop manager will again restart and your card will connect to linux and you'll be able to use the second monitor and card in linux as well.
## 6) CPU Pinning and Isolation.




