import numpy as np
import matplotlib.pyplot as plt


def hex_to_image(filename):
    values = []

    with open(filename, 'r') as f:
        for line in f:
            line = line.strip()

            # Ignore ModelSim header/comment lines
            if line.startswith('//') or line == '':
                continue

            # ModelSim unknown value
            if line.lower() == 'x':
                values.append(0)

            # Normal hexadecimal value
            else:
                values.append(int(line, 16))

    print(filename, "->", len(values), "pixels")

    # Make sure there are exactly 128x128 pixels
    if len(values) != 128 * 128:
        raise ValueError(
            f"{filename}: Expected 16384 pixels, found {len(values)}"
        )

    image = np.array(values, dtype=np.uint8).reshape(128, 128)

    return image


# ============================================================
# Read FPGA output files
# ============================================================

binary_img  = hex_to_image("binary_fpga15.txt")
eroded_img  = hex_to_image("eroded_fpga15.txt")
dilated_img = hex_to_image("dilated_fpga15.txt")
boundary_img = hex_to_image("boundary_fpga15.txt")


# ============================================================
# Display images
# ============================================================

plt.figure(figsize=(6, 6))
plt.imshow(binary_img, cmap='gray', vmin=0, vmax=1)
plt.title("FPGA Threshold Output")
plt.axis("off")
plt.show()


plt.figure(figsize=(6, 6))
plt.imshow(eroded_img, cmap='gray', vmin=0, vmax=1)
plt.title("FPGA Erosion Output")
plt.axis("off")
plt.show()


plt.figure(figsize=(6, 6))
plt.imshow(dilated_img, cmap='gray', vmin=0, vmax=1)
plt.title("FPGA Dilation Output")
plt.axis("off")
plt.show()


plt.figure(figsize=(6, 6))
plt.imshow(boundary_img, cmap='gray', vmin=0, vmax=1)
plt.title("FPGA Boundary Extraction")
plt.axis("off")
plt.show()