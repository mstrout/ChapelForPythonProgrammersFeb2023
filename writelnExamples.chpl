// writelnExamples.chpl

/*
   usage on puma/ocelote:
     chpl writelnExamples.chpl
     ./writelnExamples

   usage on laptop with podman (or docker):
     podman pull docker.io/chapel/chapel     // only have to do this once, but it takes a few minutes

     podman run --rm -v "$PWD":/myapp -w /myapp chapel/chapel chpl writelnExamples.chpl
     podman run --rm -v "$PWD":/myapp -w /myapp chapel/chapel ./writelnExamples

   For docker usage, see https://chapel-lang.org/install-docker.html

   See https://chapel-lang.org/docs/main/modules/standard/ChapelIO.html
*/

/*
   One fantastic capability of Chapel is that the compiler generates a default `writeThis` method
   for all datatypes, those provided by the language and those that are user-defined.
   This makes debugging by printing out values of those types much easier.

   In this example program, we see how `writeln` uses the default, compiler-generated
   `writeThis` method without us having to explicitly call it.
*/

writeln();

// integers and floats
var myInt : int;
var myFloat = 3.2;
writeln("Integers are default initialized to a value of 0, myInt = ", myInt);
writeln("Note we can combine strings in a writeln with a comma, myFloat = ", myFloat, "AFTERmyFloat");
writeln();

// strings
var myStringVar : string;
write("myStringVar is default initilized to the empty string, BEFORE(", myStringVar);
writeln(")AFTER");

myStringVar = "reassigning myStringVar to something else";
writeln("now myStringVar = '", myStringVar, "'");

const myStringConst = "myStringConst will always have this value";
writeln("myStringConst = [", myStringConst, "]");
//myStringConst = "something else results in an error, so I commented it out";
writeln();

// maps
use Map;

var myMap : map(int, string);
myMap.add(1,"one");
myMap.add(2,"two");
writeln("myMap = ", myMap);
writeln();


// user-defined records
record point {
  var x : int;
  var y : int;
}
var myPoint : point = new point(2,3);
writeln("myPoint = ", myPoint);
writeln();


// lists
use List;

var myList : list(point);
myList.append(new point(1,2));
myList.append(new point(3,4));
myList.append(new point(4,5));
writeln("myList = ", myList);

