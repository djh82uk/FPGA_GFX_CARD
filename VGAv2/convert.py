from PIL import Image

image = Image.open("lena64.png")
pixels = image.load()

out_file = open("lena.bin", "wb")

for y in range(75):
  for x in range(128):
    try:
      out_file.write(chr(pixels[x, y]).encode('iso-8859-1'))
    except IndexError:
      out_file.write(chr(0).encode('iso-8859-1'))

