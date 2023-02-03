// setExample

use List, Set;

var myList : list(int) = new list([3,4,5,3,4,6,7]);
var mySet  : set(int);
for item in myList { mySet.add(item); }
writeln("mySet.size = ", mySet.size);

