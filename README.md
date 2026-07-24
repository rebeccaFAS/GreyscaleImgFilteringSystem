# GreyscaleImgFilteringSystem
Implementation of a 3×3 isotropic convolution kernel for  filtering greyscale images
This repository contains codes and slide about a project: "The aim is to develop a digital architecture capable of filtering greyscale images, assessing whether it is functioning correctly and analysing the results obtained in terms of time, resources used and power dissipated".

In this project I designed and implemented a hardware circuit for filtering greyscale images (i.e. 8-bit unsigned pixels) using a 3×3 kernel with 8-bit two’s complement coefficients. The circuit incorporates both the computational logic for the isotropic convolution operation and a buffer dedicated to forming the pixel window; it also includes a control section that provides at least a ‘valid’ signal at the outputs. No rounding or saturation operations are required on the filtered pixels. Finally, the design was characterised in terms of performance by evaluating parameters such as latency, throughput, maximum operating frequency, resource utilisation and power dissipation. In parallel, a verification check was carried out to ensure the correct operation of the designed circuit with the aim of verifying that the results produced complied with the design specifications and of guaranteeing the reliability of the implemented architecture.

This branch includes:
  code: main vhdl codes for simulation;
  python code: python filtered image compared with VHDL filtered image results, namely gray scale filtered image through VHDL workflow and filtered one through python numpy library, performance evaluation and absolute error map generation between Python and VHDL outputs, i.e. asbolute error computation, peak SNR computation, SSMI and DSSIM value comparison;
  ppt: to show the result and future implementation.
  
- At the moment the italian version is only available but work is being made to translate it to english -
