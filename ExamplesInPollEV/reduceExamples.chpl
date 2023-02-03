// reduceExamples.chpl

var oneDimArray : [1..4] int = [20, 30, 40, 50];
writeln("oneDimArray = ", oneDimArray);
writeln("+ reduce oneDimArray = ", + reduce oneDimArray);

use List;
var aList : list(real) = new list([50, 20, 30, 40]);

writeln("aList = ", aList);
writeln("min reduce aList = ", min reduce aList);
