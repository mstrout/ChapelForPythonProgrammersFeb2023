Author of example: Scott Bachman


First compile the png library:
```
  cd libpng-1.6.38
  ./configure
  make
```
The result of the above should be some libraries in the `.libs/` subdirectory.

Then compile the image analysis example:
```
  cd ..
  chpl main.chpl --cpp-lines -Llibpng-1.6.38/.libs -lpng16 --fast
```

To run, do
```
  ./main -nl 4 --inname=Roatan_benthic_r3_gray.png --outname=out.png --radius=100
```

The input file is a grayscale .png, but the intensity values actually represent different 
habitat types numbered from 0 to 6.  So the grayscale values are all from 0 to 6, where the 
full range is from 0 (black) to 255 (white).  So it all looks black

The output file uses a "jet" colormap defined in png.chpl, which I scale based on the maximum 
value in the output array.

