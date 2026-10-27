# FPGA-Based Brain Tumor Detection Using Verilog HDL

# Overview

This project implements image processing techniques on an FPGA using Verilog HDL for a brain tumor detection application. The design performs thresholding, erosion, dilation, and boundary detection on grayscale image data. The processed output can be visualized through a VGA display.

# Objectives

- Implement image processing operations using Verilog HDL.
- Process grayscale images using FPGA hardware.
- Perform thresholding and morphological operations.
- Display processed images using a VGA interface.

# Theory

- Thresholding: Converts a grayscale image into a binary image based on a selected intensity threshold.
- Erosion: Reduces foreground regions and removes small structures in a binary image.
- Dilation: Expands foreground regions and can fill small gaps.
- Boundary Detection: Extracts the boundaries of foreground regions.
- FPGA Processing: Implements image processing operations as digital hardware using Verilog HDL.

# Hardware Requirements

- FPGA Development Board: DE2-115
- FPGA Device: Intel Cyclone IV E (EP4CE115F29C7)
- Display Interface: VGA
- Input: Grayscale image

# Software Environment

- HDL: Verilog
- FPGA Development: Intel Quartus Prime
- Simulation: ModelSim 
- Image Preparation: Python 

# Design Modules

Module| Function
Design Modules

Module| Function
"top.v"| Top-level module integrating the design components
"braintumor.v"| Main image processing logic
"image_memory.v"| Stores and supplies image pixel data
"threshold.v"| Performs image thresholding
"window3x3.v"| Provides a 3×3 pixel neighbourhood
"erosion.v"| Performs morphological erosion
"dilation.v"| Performs morphological dilation
"boundary.v"| Performs boundary detection
"vga_clock.v"| Generates the VGA clock
"vga_controller.v"| Controls VGA timing and display output

# Implementation

The grayscale image is converted into pixel data and stored in FPGA memory using a memory initialization file. The Verilog modules process the image data, and the selected output is sent to the VGA controller for display.

# Results

Screenshots of the original image and the processed outputs will be included in this section.

# Limitations

The implemented image processing operations assist in image segmentation and boundary extraction but do not independently confirm the presence of a brain tumor. The project is intended for educational purposes and is not a clinically validated diagnostic system.

# Repository Structure

- "rtl/" — Verilog source files
- "simulation/" — Testbench
- "image_data/" — Image and memory initialization files
- "constraints/" — Timing constraints
- "results/" — Output screenshots


