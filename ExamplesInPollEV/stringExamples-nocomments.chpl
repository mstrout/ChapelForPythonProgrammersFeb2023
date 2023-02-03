// stringExamples-nocomments.chpl

var array = [1,2,3,4];
var result = "";
for num in array {
  result += num:string + ":";
}
result = result[0..#result.size-1];
var sum : int;
for substr in result.split(":") {
  sum += substr : int;
}
writeln("sum = ", sum);
