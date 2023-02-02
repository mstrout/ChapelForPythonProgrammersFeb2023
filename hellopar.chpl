// hellopar.chpl

/*
   This is a shorter version of hello6-taskpar-dist.chpl.  It has fewer comments and uses fewer
   string operations.

   usage on puma/ocelote:
     chpl hellopar.chpl
     ./hellopar -nl 2

     # something else to try
     ./hellopar -nl 4 --tasksPerLocale=3

   usage on laptop with docker:
     docker pull docker.io/chapel/chapel-gasnet // only do this once, but it takes a few minutes

     docker run --rm -v "$PWD":/myapp -w /myapp chapel/chapel-gasnet chpl hellopar.chpl
     docker run --rm -v "$PWD":/myapp -w /myapp chapel/chapel-gasnet ./hellopar -nl 4

     # something else to try
     docker run --rm -v "$PWD":/myapp -w /myapp chapel/chapel-gasnet ./hellopar -nl 4 --tasksPerLocale=3
*/


// The number of tasks to use per locale.  Specify on command line with --tasksPerLocal=n,
// where n is some number.
config const tasksPerLocale = 1;

// Creates a task per locale
coforall loc in Locales on loc {
  coforall tid in 0..#tasksPerLocale {

    writeln("Hello world! (from task ", tid, " of ", tasksPerLocale,
            " on locale ", here.id, " of ", numLocales, ")");
  }
}

