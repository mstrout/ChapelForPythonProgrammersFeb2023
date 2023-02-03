// listExample.chpl

use List;

var list1 : list(int);
list1.append(1);
list1.append(2);
list1.append(3);
list1.append(4);

var list2 : list(string);
list2.append("a");
list2.append("b");
list2.append("c");
list2.append("d");

for (i,j) in zip(list2,list1) {
  writeln("(i,j) = ", (i,j));
}

