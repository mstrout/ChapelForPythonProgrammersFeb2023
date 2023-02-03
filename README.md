# ChapelForPythonProgrammersFeb2023

Chapel code examples using for February 3rd tutorial at the University of Arizona.

slack invite for asking questions during (and somewhat after) the tutorial:
https://join.slack.com/t/slack-jc92899/shared_invite/zt-1ogsmct8k-9KisCd6kv~ivmKyvS3sJlg

See the Chapel Workshop tab at https://public.confluence.arizona.edu/display/UAHPC/Training 
for information about where the tutorial is being held.

## Participating in the tutorial

* Poll Everywhere link: https://pollev.com/michellestrout402

* Attempt this Online website for running Chapel code
  * Go to main Chapel webpage at https://chapel-lang.org/
  * Click on the little ATO icon on the lower left that is above the YouTube icon

* Using a container on your laptop
  * First, install podman or docker for your machine and then start them up
  * Then, the below commands work with podman or docker
```
 podman pull docker.io/chapel/chapel     // takes about 3 minutes
 git clone git@github.com:mstrout/ChapelForPythonProgrammersFeb2023.git
 cd ChapelForPythonProgrammersFeb2023
 podman run --rm -v "$PWD":/myapp -w /myapp chapel/chapel chpl hello.chpl
 podman run --rm -v "$PWD":/myapp -w /myapp chapel/chapel ./hello
```

* Chapel on Puma and Ocelote
Get to a login node
```
$ ssh yourNetid@hpc.arizona.edu
[yourNetid@gatekeeper ~]$ shell
```

Set up your ssh key and clone the tutorial repository. These things only need to be done once, and they can be done on the login node.

```
$ ssh-keygen     # hit return to all the questions
$ cp ~/.ssh/id_rsa.pub  ~/.ssh/authorized_keys

$ git clone https://github.com/mstrout/ChapelForPythommersFeb2023.git
```

Ask for an allocation of 2 nodes.
```
$ salloc --exclusive -N 2 --account=youraccount --partition=standard --time=01:00:00
```


Once you have the allocation...

Load Chapel:

```
$ module load chapel-udp
```

Set up gasnet:

```
$ export GASNET_SPAWNFN=S
$ export GASNET_SSH_SERVERS=`scontrol show hostnames | xargs echo`
```
Compile your program:
```
$ cd ChapelForPythonProgrammersFeb2023
$ chpl hello6-taskpar-dist.chpl
```

Run it:
```
$ ./hello6-taskpar -nl 2
   # 2 is the number of locales to create. It cannot exceed the -N option to salloc above.

$ ./hello6-taskpar -nl 2 --tasksPerLocale=7
```

## Code Examples in this repository

For these code examples to compile and run as described in the "usage" message at the
top of each source file, make sure you have installed, initialized, and started
podman, or docker, as described below in Prerequisites.

* `hello.chpl`, serial version of hello world

* `hello6-taskpar-dist.chpl`, distributed and thread parallel version

* `kmer.chpl`, serial kmer counting program, `kmer_large_input_file.txt` is example input

* `diffusion.chpl`, a parallel implementation of heat diffusion

## Chapel Tutorial for Python Programmers: Productivity and Performance in One Language

Many users of HPC systems are also Python programmers. Python is a great
programming language for prototyping data analyses and simulations, but things
become more challenging when trying to leverage cross-node and within-node
parallelism. In this tutorial, we present the general-purpose Chapel
programming language for productive, parallel programming. Participants can
experiment with Chapel code examples from applications such as k-mer counting,
solving a diffusion PDE, sorting, and image processing. For hands-on
activities, we provide a container for quick setup and instructions on how to
use Chapel on the UArizona HPC systems. Active learning exercises such as
online multiple choice about converting common Python patterns into Chapel code
enable participants to check what they have learned. Throughout the tutorial,
existing large applications written in Chapel are highlighted with quotes from
their developers and example code snippets showing Chapel usage in production.
We also give a brief introduction to Chapel's newfound support for GPU
programming. Come join us for a fun couple of hours exploring how to write
parallel programs in a productive and performant way!

## Prerequisites

Please install podman (https://podman.io/) on your laptop beforehand or bring
along a friend who has it installed on their laptop and is willing to share.
Here is how you could install and start it on a mac:

    brew install podman                  # ignore the llvm15 dep error
    podman machine init
    podman machine start
    podman machine stop                  # what you can use to stop it

Here are the commands you can use to do an initial test of chapel ahead of time
if you would like:

    podman pull docker.io/chapel/chapel     # takes about 3 minutes
    mkdir ChapelSandbox             # optional: create a directory for storing chapel files
    cd ChapelSandbox
    echo 'writeln("Hello, world!");' > hello.chpl
    podman run --rm -v "$PWD":/myapp -w /myapp chapel/chapel chpl hello.chpl
    podman run --rm -v "$PWD":/myapp -w /myapp chapel/chapel ./hello

The '-v "$PWD":/myapp -w /myapp' options to podman (and docker) will map your current
directory ($PWD) to the directory /myapp in the container and then set /myapp to the
working directory in the container.  Therefore, these one off commands are running
the chpl compiler in the container on the files in your current subdirectory on your
laptop.  The executable files are also put into your current directory.

## Running multi-locale/node runs

On your laptop, you need to use docker for the container that emulates multinode executions. 
The current docker container doesn't work with podman just yet.  Here are the instructions:

    docker pull docker.io/chapel/chapel-gasnet     # takes about 3 minutes
    echo 'writeln("Hello, world!");' > hello.chpl
    docker run --rm -v "$PWD":/myapp -w /myapp chapel/chapel-gasnet chpl hello.chpl
    docker run --rm -v "$PWD":/myapp -w /myapp chapel/chapel-gasnet ./hello -nl 2
