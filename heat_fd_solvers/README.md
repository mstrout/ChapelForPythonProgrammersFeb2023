# Chapel Heat/Diffusion equation example

The examples in this directory, show how one might write a simple 2D finite difference solver for the heat equation in Chapel.

The single-node version is based on this [Python tutorial](https://nbviewer.org/github/barbagroup/CFDPython/blob/master/lessons/09_Step_7.ipynb). The distributed version is an extension of the single-node code that allows the same simulation to run across multiple compute nodes using distributed arrays and Chapel's high-level parallel constructs.

## Compiling and Running on a single node

1. Follow [these instructions](https://chapel-lang.org/download.html) on this page to download and install Chapel

2. In a terminal, execute the following command to compile the serial version of the code:
```bash
chpl heat_2d.chpl --fast
```

3. Execute the following to run the simulation:
```bash
./heat_2d
```
If all goes well, you should see an output like the following. The mean and standard-deviation of the solution grid are printed out as well as the elapsed time spent in the kernel.
```
mean: 1.07588 stdDev: 0.102424
elapsed time: 0.011921 seconds
```

4. A variety of parameters can be manipulated from the command line. For example, the following command would run the simulation with twice as many time steps:
```bash
./heat_2d --nt=100
```

## Compiling and Running on multiple nodes

1. Follow the instructions [here](https://chapel-lang.org/docs/usingchapel/multilocale.html) to configure your Chapel installation for multi-locale execution

2. In a terminal, compile the distributed version of the program:
```bash
chpl heat_2d_dist.chpl --fast
```

3. Execute the program on the desired number of compute nodes (locales). Here, it is running on two locales:
```bash
./heat_2d_dist -nl 2
```

4. As with the single-node version, command line arguments can be used to manipulate a variety of simulation parameters.

## All command line parameters:

| name | default | type | description |
|:--- | :--- | :--- | :--- |
| xLen | 2.0 | real | physical size of the grid in 'x' |
| yLen | 2.0 | real | physical size of the grid in 'y' |
| nx | 31 | int | number of grid points along 'x' |
| ny | 31 | int | number of grid points along 'y' |
| nt | 50 | int | number of simulated time steps |
| sigma | 0.25 | real | simulation stability parameter (determines time-step)|
| nu | 0.05 | real | material parameter (viscosity in the case of fluid) |
