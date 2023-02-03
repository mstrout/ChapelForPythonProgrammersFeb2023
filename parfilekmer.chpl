// parfilekmer.chpl
/*
   usage on puma/ocelote:
     chpl parfilekmer.chpl
     ./parfilekmer -nl 2

   usage on laptop with podman (or docker):
     docker run --rm -v "$PWD":/myapp -w /myapp chapel/chapel-gasnet chpl parfilekmer.chpl
     docker run --rm -v "$PWD":/myapp -w /myapp chapel/chapel-gasnet ./parfilekmer

     # can change the infilename on command line because it is a configuration const
     podman run --rm -v "$PWD":/myapp -w /myapp chapel/chapel ./kmer --infilename="kmer.chpl"

   kmer_large_input.txt is from
   https://www.ncbi.nlm.nih.gov/nuccore/NC_001422.1?report=fasta
 */

use Map, IO;
use FileSystem, BlockDist;

config const k = 4;             // kmer length to count
config const dir = "DataDir";   // subdirectory for all data

// find all the files in the given subdirectory and put them in a distributed array
var fList = findFiles(dir);
var filenames = newBlockArr(0..#fList.size,string);
filenames = fList;

// per file kmer count
forall f in filenames {
  // read in the input sequence from the file infile and strip out newlines
  var sequence, line : string;
  var infile = open(f, iomode.r).reader();
  while infile.readLine(line) {
    sequence += line.strip();
  }

  // declare a dictionary/map to store the count per kmer
  var nkmerCounts : map(string, int);

  // count up the number of times each kmer occurs
  for ind in 0..<(sequence.size-k) {
    nkmerCounts[sequence[ind..#k]] += 1;
  }

  writeln("Number of unique k-mers in ", f, " is ", nkmerCounts.size);
  writeln();
}


