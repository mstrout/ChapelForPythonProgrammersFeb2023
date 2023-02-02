/* usage:
    chpl writeExample.chpl
    ./writeExample
*/

writeln("Option 1:");

var x = 42;
var str = "answer";
writeln(str, " = ", x);

// other examples that are valid Chapel code
// but don't match the python print example

writeln();
writeln("Option 2:");

config const tasksPerLocale = 2;
coforall tid in 0..#tasksPerLocale {
  var message = "answer = ";
  message += 42:string;
  writeln(message);
}


{// creating an unnamed scope so 'x' is not declared twice
writeln();
writeln("Option 3:");

var x = 42;
var str = "answer";
coforall loc in Locales {
  on loc {
    writeln(x, " = ", str);
  }
}

}
