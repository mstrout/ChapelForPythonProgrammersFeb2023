// hello.chpl
/*
   usage on puma/ocelote:
     chpl hello.chpl
     ./hello

   usage on laptop with podman (or docker):
     podman pull docker.io/chapel/chapel     // only have to do this once, but it takes a few minutes

     podman run --rm -v "$PWD":/myapp -w /myapp chapel/chapel chpl hello.chpl
     podman run --rm -v "$PWD":/myapp -w /myapp chapel/chapel ./hello

   For docker usage, see https://chapel-lang.org/install-docker.html

   See https://chapel-lang.org/docs/examples/index.html

   1/25/23, downloaded from 
   https://github.com/chapel-lang/chapel/blob/main/test/release/examples/hello.chpl
*/

// Simple hello world
writeln("Hello, world!");    // print 'Hello, world!' to the console

