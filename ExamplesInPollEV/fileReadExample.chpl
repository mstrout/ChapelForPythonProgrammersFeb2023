// read in a file into a list of strings
// where each string has a line with the newline at the end removed

use List, IO;

var line : string;
var lines : list(string);
var infile = open("filename.txt",iomode.r).reader();
while infile.readLine(line) {
  lines.append(line.strip());
}

writeln(lines);
