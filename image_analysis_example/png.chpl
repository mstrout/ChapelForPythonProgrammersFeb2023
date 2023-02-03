
/*****
        rw_png_v5.chpl -
        Program that reads a PNG file from disk, prints the RGB values found
        at one pixel, changes it to 1, 2, 3, and writes the change to disk.
        This version is based on rw_png_3b and adds an argument to PNG_write
        to save one or all color planes.

        Call:
          rw_png_v5
            --inname=<file>    file to read from
            --outname=<file>   file to write to
            --x=<#>            x coordinate of pixel to print
            --y=<#>            y coordinate of pixel to print

        c 2015-2018 Primordial Machine Vision Systems
        Copied initially from http://primachvis.com/html/imgproc_chapel.html
*****/

module png {

use Help;
use CTypes;
use Time;
use AutoMath;

/* Command line arguments.
config const inname : string;           /* name of file to read */
config const outname : string;          /* file to create with modded pixel */
config const x : c_int = -1;            /* pixel to change */
config const y : c_int = -1;            /* pixel to change */
*/

/* The C image data structure. */
extern "_rgbimage" record rgbimage {
  var ncol : c_int;                     /* width (columns) of image */
  var nrow : c_int;                     /* height (rows) of image */
  var npix : c_int;                     /* number pixels = w * h */
  var r : c_ptr(c_uchar);               /* red plane */
  var g : c_ptr(c_uchar);               /* green plane */
  var b : c_ptr(c_uchar);               /* blue plane */
}

/* Can't import an enum directly from C; need to grab each component. */
extern const CLR_GREY : int(32);
extern const CLR_RGB : int(32);
extern const CLR_R : int(32);
extern const CLR_G : int(32);
extern const CLR_B : int(32);

/* Our variables */
var rgb : rgbimage;                     /* the image we read */
// var rgb = new borrowed rgbimage();
var xy : int(32);                       /* 1D index of x, y coord */
var retval : c_int;                     /* return value with error code */

/* External img_png linkage. */
require "png.h", "png.c";
extern proc PNG_read(fname : c_string, img : c_ptr(c_ptr(rgbimage))) : c_int;
extern proc PNG_write(fname : c_string, img : c_ptr(rgbimage), plane : c_int) : c_int;
extern proc free_rgbimage(img : c_ptr(c_ptr(rgbimage))) : void;
extern proc PNG_isa(fname : c_string) : c_int;


proc load_PNG_into_array(fname : string, t : stopwatch) {

  // Read in PNG
  var rgb_ptr : c_ptr(rgbimage);
  var retval = PNG_read(fname.c_str(), c_ptrTo(rgb_ptr));
  var rgb = rgb_ptr.deref();

  writeln("Elapsed time to dereference PNG: ", t.elapsed(), " seconds.");

  // Cast these variables to int(64), because it makes things easier later on
  var rgbr = rgb.nrow : int;
  var rgbc = rgb.ncol : int;

  var Image: [0..(rgbr-1), 0..(rgbc-1)] int;

  forall i in 0..(rgb.npix-1) {
    Image[i / rgb.ncol, i % rgb.ncol] = rgb.r[i+1];
  }

  return (rgb_ptr, Image);
}

proc write_array_to_PNG(outfile : string, array : ?, rgb_ptr: ?, t : stopwatch) {

  // Read in PNG
  var rgb = rgb_ptr.deref();

  var maxval = max reduce(array);
  writeln("Maxval: ", maxval);

  // Assign a jet colormap based on the values in the array
  forall element in array.domain do {

    var xy = (element[0] * rgb.ncol) + element[1];

    if array[element] == 0.0 {
      rgb.r[xy] = 0 : uint(8);
      rgb.g[xy] = 0 : uint(8);
      rgb.b[xy] = 0 : uint(8);
    }
    else if array[element] == -999.0 {
      rgb.r[xy] = 255 : uint(8);
      rgb.g[xy] = 255 : uint(8);
      rgb.b[xy] = 255 : uint(8);
    }
    else {
      rgb.r[xy] = (min(max( 0, 1.5 - abs(1 - 4*( array[element]/maxval - 0.50))),1) * 255) : uint(8);
      rgb.g[xy] = (min(max( 0, 1.5 - abs(1 - 4*( array[element]/maxval - 0.25))),1) * 255) : uint(8);
      rgb.b[xy] = (min(max( 0, 1.5 - abs(1 - 4*( array[element]/maxval       ))),1) * 255) : uint(8);
    }


  }

  writeln("Elapsed time to set colors: ", t.elapsed(), " seconds.");

  retval = PNG_write(outfile.c_str(), rgb_ptr, CLR_RGB);
}


// END OF MODULE
}
// END OF MODULE


/* The rest of the interface we don't use now. */
/*
extern proc alloc_rgbimage(ref img : rgbimage,
                           ncol : c_int, nrow : c_int) : c_int;
extern proc read_rgb(img : rgbimage, x, y : c_int,
                     ref r, ref g, ref b : c_uchar) : c_int;
extern proc write_rgb(img : rgbimage, x, y : c_int, r, g, b : c_uchar) : c_int;
*/

/*

/***
    usage - Print an error message along with the system help, then exit.
    args:   msg - message to print
***/
proc usage(msg : string) {

  writeln("\nERROR");
  writeln("  ", msg);
  printUsage();
  halt();
  exit(1);
}
*/

/***
    end_onerr:  Check the error code; if OK (>= 0) do nothing.  Else release
                any objects passed as additional arguments - anything can
                be passed and its type will determine the action that needs
                to be done - and exit with an non-zero error value.
    args:       retval - error code/return to value for exit
                inst - variable list of instances to free
***/
/*** proc end_onerr(retval : int, inst ...?narg) : void {

/*
  if (0 <= retval) then return;

  /* Note we skip the argument if we don't know how to clean it up. */
  for param i in 1..narg {
    if (inst(i).type == rgbimage) then free_rgbimage(inst(i));
    else if isClass(inst(i)) then delete inst(i);
  }
  exit(1);
}
*/

***/

/**** Top Level ****/

/* First sanity check the arguments, then read the image, get the pixel
   requested, change it, and write it back out.  Finally we need to free
   the allocation made in PNG_read. */
/*

if (x < 0) then
  usage("missing --x or value < 0");
if (y < 0) then
  usage("missing --y or value < 0");
if ("" == inname) then
  usage("missing --inname");
if (!PNG_isa(inname.c_str())) then
  usage("input file not a PNG picture");
if ("" == outname) then
  usage("missing --outname");

var t : stopwatch;
var rgb_ptr : c_ptr(rgbimage);

t.start();
retval = PNG_read(inname.c_str(), c_ptrTo(rgb_ptr));
rgb = rgb_ptr.deref();
// end_onerr(retval, rgb);
t.stop();
writeln("Elapsed time to read: ", t.elapsed(), " seconds.");

if (rgb.ncol <= x) {
  free_rgbimage(c_ptrTo(rgb_ptr));
  usage("--x (0-based) >= image width");
}

writeln(rgb.nrow);
if (rgb.nrow <= y) {
  free_rgbimage(c_ptrTo(rgb_ptr));
  usage("--y (0-based) >= image height");
}

/* Now we can access the fields directly. */
//xy = (y * rgb.ncol) + x;
//writef("\nRead %4i x %4i PNG image\n", rgb.ncol, rgb.nrow);
//writef("At %4i,%4i      R %3u  G %3u  B %3u\n\n", x,y,
//       rgb.r(xy), rgb.g(xy), rgb.b(xy));

//rgb.r(xy) = 1;
//rgb.g(xy) = 2;
//rgb.b(xy) = 3;

//retval = PNG_write(outname.c_str(), rgb_ptr, CLR_RGB);
retval = PNG_write(outname.c_str(), rgb_ptr, CLR_GREY);
//end_onerr(retval, rgb);

free_rgbimage(c_ptrTo(rgb_ptr));

*/
