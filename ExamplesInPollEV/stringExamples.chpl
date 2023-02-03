// stringExamples.chpl

/*
   usage on puma/ocelote:
     chpl stringExamples.chpl
     ./stringExamples

   usage on laptop with podman (or docker):
     podman pull docker.io/chapel/chapel     // only have to do this once, but it takes a few minutes

     podman run --rm -v "$PWD":/myapp -w /myapp chapel/chapel chpl stringExamples.chpl
     podman run --rm -v "$PWD":/myapp -w /myapp chapel/chapel ./stringExamples

   For docker usage, see https://chapel-lang.org/install-docker.html

   See more about strings at https://chapel-lang.org/docs/language/spec/strings.html
*/

/*
   Some examples of manipulating strings.
*/

// start with an array of integers
var array = [1,2,3,4];

writeln();
writeln("array = ", array);

// convert each integer into a string and concatenate them all separated by colons
var result = "";
for num in array {
  result += num:string + ":";
}
result = result[0..#result.size-1];     // take off that last colon
writeln("result = ", result);

// how many characters are in the string?
writeln("result.size = ", result.size);

// iterate by the substrings by splitting on the colon and convert strings back to integers
var sum : int;
for substr in result.split(":") {
  sum += substr : int;
}
writeln("sum = ", sum);
