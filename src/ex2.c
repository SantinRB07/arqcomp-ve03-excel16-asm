//---------------------------------
// Lab 6: Pixel Conversion
//---------------------------------

#include<stdio.h>

int pixels[] = {0x00010000,     0x010101,       0x6,            0x3333, 
                0x030c,         0x700853,       0x294999,       -1};

int rgb_to_gray(int red, int green, int blue) {
	return (red + green + blue) / 3;
}

int main() {

	int i=0;
	int rgb, red, green, blue, gray;

	printf("Converting pixels to grayscale:\n");

	while (pixels[i] != -1) {
		rgb = pixels[i];
		blue = 	rgb & 0xff;
		green = (rgb >> 8) & 0xff;
		red = 	(rgb >> 16) & 0xff;
		gray = rgb_to_gray(red, green, blue);
		printf("%d\n", gray);
		i++;
	}
	printf("Finished.\n");
}
