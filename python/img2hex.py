import cv2
import matplotlib.pyplot as plt
from google.colab import files
from PIL import Image
from google.colab import files

img = cv2.imread("/content/img1.jpeg")
plt.imshow(img)
plt.axis("off")
plt.show()


gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

# Resize to 128 × 128
gray = cv2.resize(gray, (128, 128))

plt.imshow(gray, cmap="gray")
plt.axis("off")
plt.show()

with open("hex1.txt", "w") as f:
    for pixel in gray.flatten():
        f.write(f"{pixel:02X}\n")
		
files.download("hex10.txt")