use png;
use distance_mask;
use BlockDist;
use Time;
use AutoMath;
use LinearAlgebra;

/* Command line arguments. */
config const inname : string;                /* name of PNG file to read */
config const outname : string;               /* name of PNG file to write at the end */
config const radius : int;                  /* the radius of the convolution window (in pixels) */


proc convolve_and_calculate(Image: [] int(64), centerPoints : ?, Mask : [] bool, MaskDomain : ?, Output: [] real, t: stopwatch) : [] {

  forall center in centerPoints {
    var scalar : int = 0;
    for m in MaskDomain {
      scalar += Image[center + m] * Mask[m];
    }
    Output[center] = scalar;
  }

  writeln("Elapsed time on ", here.name, ": ", t.elapsed(), " seconds for domain ", centerPoints);

}


proc main(args: [] string) {

  var t : stopwatch;
  t.start();

  writeln("Distance circle has a radius of ", radius, " points.");

  // Read in PNG
  var (rgb_ptr, Image) = load_PNG_into_array(inname, t);
  const ImageSpace = Image.domain;
  writeln("ImageSpace is ", ImageSpace);
  writeln("Elapsed time to read into array: ", t.elapsed(), " seconds.");

  // Create distance mask
  var Mask = create_distance_mask(radius);

  // Create Block distribution of interior of PNG
  const offset = radius;  // This is needed so we don't try to convolve the window off the edge of the image
  const Inner = ImageSpace.expand(-offset);
  const myTargetLocales = reshape(Locales, {1..Locales.size, 1..1});
  const D = Inner dmapped Block(Inner, targetLocales=myTargetLocales);
  var OutputArray : [D] real;

  writeln("Elapsed time at start of coforall loop: ", t.elapsed(), " seconds.");

  writeln("Starting coforall loop.");

  coforall loc in Locales do on loc {

    // If I put "create_distance_mask" inside this loop I need to declare local copies of these variables,
    // otherwise it seems like Chapel will have to do a ton
    // of cross-locale calls to access these variables. This seems to double the amount of time it
    // takes to run through the coforall loop for all non-head locales!

    const locImageDomain = Image.domain;
    const locImage : [locImageDomain] Image.eltType = Image;

    const locMaskDomain = Mask.domain;
    const locMask : [locMaskDomain] Mask.eltType = Mask;

    convolve_and_calculate(locImage, D.localSubdomain(), locMask, locMaskDomain, OutputArray, t);
  }


  writeln("Elapsed time to finish coforall loop: ", t.elapsed(), " seconds.");

  // Gather back to the head node
  var GatheredArray : [Inner] real;
  GatheredArray = OutputArray;

  write_array_to_PNG(outname, GatheredArray, rgb_ptr, t);

  writeln("Elapsed time to write PNG: ", t.elapsed(), " seconds.");
}

