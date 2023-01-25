# ChapelForPythonProgrammersFeb2023

Chapel code examples using for February 3rd tutorial at the University of Arizona.
See the Chapel Workshop tab at https://public.confluence.arizona.edu/display/UAHPC/Training for information about
where the tutorial is being held.

## Code Examples

For these code examples to compile and run as described in the "usage" message at the
top of each source file, make sure you have installed, initialized, and started
podman as described below in Prerequisites.

* hello.chpl, serial version of hello world
* hello6-taskpar-dist.chpl, distributed and thread parallel version


## Chapel Tutorial for Python Programmers: Productivity and Performance in One Language

Many users of HPC systems are also Python programmers. Python is a great programming language for prototyping data analyses and simulations, but things become more challenging when trying to leverage cross-node and within-node parallelism. In this tutorial, we present the general-purpose Chapel programming language for productive, parallel programming. Participants can experiment with Chapel code examples from applications such as k-mer counting, solving a diffusion PDE, sorting, and image processing. For hands-on activities, we provide a container for quick setup and instructions on how to use Chapel on the UArizona HPC systems. Active learning exercises such as online multiple choice about converting common Python patterns into Chapel code enable participants to check what they have learned. Throughout the tutorial, existing large applications written in Chapel are highlighted with quotes from their developers and example code snippets showing Chapel usage in production.  We also give a brief introduction to Chapel's newfound support for GPU programming. Come join us for a fun couple of hours exploring how to write parallel programs in a productive and performant way!

## Prerequisites

Please install podman (https://podman.io/) on your laptop beforehand or bring along a friend who has it installed on their laptop and is willing to share.  Here is how you could install and start it on a mac:

    brew install podman                     // ignore the llvm15 dep error
    podman machine init
    podman machine start
    podman machine stop                  // what you can use to stop it

Here are the commands you can use to do an initial test of chapel ahead of time if you would like:

    podman pull docker.io/chapel/chapel     // takes about 3 minutes
    echo 'writeln("Hello, world!");' > hello.chpl
    podman run --rm -v "$PWD":/myapp -w /myapp chapel/chapel chpl -o hello hello.chpl
    podman run --rm -v "$PWD":/myapp -w /myapp chapel/chapel ./hello
