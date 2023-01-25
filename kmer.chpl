// kmer.chpl
/*
   usage on puma/ocelote:
     chpl kmer.chpl
     ./kmer

   usage on laptop with podman (or docker):
     podman run --rm -v "$PWD":/myapp -w /myapp chapel/chapel chpl kmer.chpl
     podman run --rm -v "$PWD":/myapp -w /myapp chapel/chapel ./kmer

   For docker usage, see https://chapel-lang.org/install-docker.html

   Original version of kmer counting algorithm provided by
   Aryamaan Jain (github strikeraryu) on Chapel Discourse April 7, 2021.

   kmer_large_input.txt is from
   https://www.ncbi.nlm.nih.gov/nuccore/NC_001422.1?report=fasta
 */

use Map;
use IO;

// to have it read a different input file, run as follows:
//      ./kmer --infile="anotherFileName"
config const infile = "kmer_large_input.txt";

// set k to something different on the commandline with
//      ./kmer --k=7
config const k = 4;

// main
writeln("Number of unique k-mers in ", infile, " is ", numUniqueKmers());

// helper procedures
proc numUniqueKmers() : int {
  var sequence : string;

  var f = open(infile, iomode.r);
  var fReader =  f.reader();

  var nkmerCounts : map(string, int);

  if(!fReader.read(sequence)) {
      halt("File read error");
  } else {
      kmerCountSerial(sequence, 0, sequence.size-1, k, nkmerCounts);
      writeln(nkmerCounts);
  }
  return nkmerCounts.size;
}

/**
    to find a map of Kmer counts serial

    arguments
    dnaSequence string                        -> string to be used for Kmer counting
    l int                                     -> left bound
    r int                                     -> right bound
    k int                                     -> len of a k-mer
    kmerCounts map((string, int, true)) (ref) -> a map of all Kmer and their counts
**/
proc kmerCountSerial(dnaSequence : string, l : int, r : int, k : int,
                     ref kmerCounts : map(string, int, false)) {
    for ind in l..<(r-k+2) {
        kmerCounts[dnaSequence[ind..#k]] += 1;
    }
}

