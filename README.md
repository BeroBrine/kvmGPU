## Single GPU Laptop passthrough guide.
This guide will help those with dual monitor setup as we will be able to use the second monitor for both linux and virtual machine vm without the need for rebooting. But this will also be as useful for desktop single GPU users as well. <br>
> This guide will be beginner friendly.
> > I'll be explaining all the steps taken and will also quote the failures i faced in that step

## System Description
My system description is visible in below screenshot. <br />
Laptop:- Legion 5i <br />
OS:- Arch Linux *(I use Arch btw!)* <br>
Kernel:- 6.1.52-1-lts (long term support)
Cpu:- Intel i5-10500H <br />
Gpu:- Nvidia rtx 3050 **--> This is the gpu we will be passing to the win10 VM**
![ss](https://github.com/BeroBrine/kvmGPU/assets/74451882/d22f9bea-b155-4cb7-b0db-e246089f88f3)



