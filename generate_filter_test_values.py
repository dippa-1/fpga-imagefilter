import numpy as np

image = [255, 255, 255, 0, 0, 0, 0, 0, 0]

SobelY = [1, 2, 1, 0, 0, 0, -1, -2, -1]
SobelX = [-1, 0, 1, -2, 0, 2, -1, 0, 1]
Sobel = np.array([0, 1, 1, -1, 0, 1, -1, -1, 0])/6
print('Sobel', Sobel)

outputs = []
for try_num in range(16):
    image = np.random.randint(255, size=9)
    output = 0
    for i in range(len(image)):
        output += image[i] * Sobel[i]
    output = int(output + 128)
    outputs.append(output)
    print('(')
    print(f'input => (x"{image[1]:02x}", x"{image[2]:02x}", x"{image[3]:02x}", x"{image[5]:02x}", x"{image[6]:02x}", x"{image[7]:02x}"),')
    print(f'output => x"{output:02x}"')
    print('),')

print(f"Min: {np.min(outputs)}, Max: {np.max(outputs)}")
