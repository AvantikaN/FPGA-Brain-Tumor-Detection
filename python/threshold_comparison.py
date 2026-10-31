import cv2
import matplotlib.pyplot as plt

img = cv2.imread("/content/img1.jpeg")

gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
gray = cv2.resize(gray, (128, 128))

thresholds = [100, 120, 140, 160, 180, 200]

plt.figure(figsize=(15, 8))

for i, T in enumerate(thresholds):

    binary = (gray >= T).astype('uint8') * 255

    plt.subplot(2, 3, i+1)
    plt.imshow(binary, cmap='gray')
    plt.title(f"Threshold = {T}")
    plt.axis("off")

plt.show()