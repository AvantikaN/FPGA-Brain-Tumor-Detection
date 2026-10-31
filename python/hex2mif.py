
# Convert hex1.txt to a Quartus-compatible image.mif

input_file = "hex1.txt"
output_file = "image1.mif"

# Read hexadecimal pixel values
with open(input_file, "r") as f:
    pixels = [line.strip() for line in f if line.strip()]

# Validate the pixel values
if len(pixels) != 16384:
    raise ValueError(
        f"Expected 16384 pixels for a 128x128 image, "
        f"but found {len(pixels)}."
    )

for i, pixel in enumerate(pixels):
    pixel = pixel.removeprefix("0x").removeprefix("0X")

    if not all(c in "0123456789abcdefABCDEF" for c in pixel):
        raise ValueError(f"Invalid hexadecimal value at line {i + 1}: {pixel}")

    value = int(pixel, 16)

    if value > 255:
        raise ValueError(f"Pixel value exceeds 8 bits at line {i + 1}: {pixel}")

    pixels[i] = f"{value:02X}"

# Generate the MIF file
with open(output_file, "w") as f:
    f.write("WIDTH=8;\n")
    f.write("DEPTH=16384;\n\n")
    f.write("ADDRESS_RADIX=UNS;\n")
    f.write("DATA_RADIX=HEX;\n\n")
    f.write("CONTENT BEGIN\n")

    for address, pixel in enumerate(pixels):
        f.write(f"    {address} : {pixel};\n")

    f.write("END;\n")

print(f"Successfully created {output_file}")
print(f"Total pixels: {len(pixels)}")
print("First 10 pixels:", pixels[:10])
