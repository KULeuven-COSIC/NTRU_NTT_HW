# NTRU_NTT_HW

This repo contains the source code for my thesis work done for my masters degree at ESAT, KULeuven.  
The thesis text can be found here: https://www.esat.kuleuven.be/cosic/publications/thesis-412.pdf.

### Abstract
In this work a hardware accelerator for the polynomial multiplication of NTRU is proposed. The proposed design
is optimised for area, and can accept different NTRU parameter
sets at run-time. The accelerator utilises the NTT domain to speed
up the polynomial multiplication. Drawbacks of this approach
are discussed as NTRU is not designed for NTT. However, this
does not come without drawbacks as the NTRU algorithm was
not designed with this trick in mind, unlike some other PQC
algorithms such as Kyber. A variety of optimisation techniques
are proposed, some of which are unique to hardware. Among
the techniques proposed is a simulated quad port block RAM
using common dual port RAM blocks, by exploiting the nature of
memory access during NTT butterfly operations. Other proposed
techniques include optimisations for the first and last NTT layers,
and moving the constant division from the end of the inverseNTT forwards to the start of forward-NTT. It is executed on
the ternary input polynomial, allowing the division to be trivially
hardcoded. Our hardware accelerator has a resource requirement
of 1764 LUTs, 1553 FFs and 6 (36 kB) BRAMs, adding up
to a total of 570 slices. It is able to calculate the polynomial
multiplication for ntruhps2048509 and ntruhps4096821 in 94 µs
and 201 µs respectively, whereas in software this takes 780 µs and 2010 µs on a powerful processor.

### Instructions

These are instructions for both simulating and compiling the accelerator.  

1. Create a new Vivado project (Vivado 2018.2 was used to develop this repo) and choose *Zedboard Zynq Evaluation and Development Kit* as target platform.
1. Add all the files in the folders `ntru_ntt_hw/src/`, `ntru_ntt_hw/src_ip/`, `ntru_ntt_hw/sim/` and `ntru_ntt_hw/mem/` to the project.
1. Select the 3 Vivado multiplier IPs in the IP Sources tab and choose *Generate Output Products* in the right-click menu.
1. In project options, change the following:
	- Under Simulation, change the target language to *Mixed*.
	- Change the Synthesis strategy to *Flow_PerfOptimized_high*.
	- Change the Implementation strategy to *Performance_ExploreWithRemap*.
1. Create a block diagram containing the `ntru_polymul` module. An example block diagram is provided below.
![Example block diagram](https://user-images.githubusercontent.com/6313423/121974333-6f7dfb00-cd7f-11eb-9e6c-71f164dcf9d6.png)
