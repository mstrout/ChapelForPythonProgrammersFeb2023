import Time.stopwatch;
import BlockDist.Block;
use CommDiagnostics;

// ---- set up simulation parameters ------
// declare configurable parameters with default values
config const xLen = 2.0,    // length of the grid in x
             nx = 31,       // number of grid points in x
             nt = 50,       // number of time steps
             sigma = 0.25,  // stability parameter
             nu = 0.05;     // viscosity

// declare non-configurable parameters
const dx : real = xLen / (nx - 1),          // grid spacing in x
      dt : real = sigma * dx / nu,          // time step size
      nTasksPerLoc = here.maxTaskPar,       // number of tasks
      nTasks = Locales.size * nTasksPerLoc, // total number of tasks
      npt = nx / nTasks;                    // number of grid points per task

param LEFT = 0, RIGHT = 1;

var t = new stopwatch();

// ---- set up the grid ------
// define a domain and distribution to describe the grid
const indices = {0..<nx},
      Indices: domain(1) dmapped Block(indices) = indices;

// define a distributed 2D array over the above domain
var u : [Indices] real;

// set up initial conditions
u = 1.0;
u[(0.5 / dx):int..<(1.0 / dx + 1):int] = 2;

proc work(tid: int, ref ghosts: [] sync real) {
  // define region of the global array owned by this task
  const lo = tid * npt,
        hi = min((tid + 1) * npt, nx);

  const taskIndices = {lo..<hi},
        taskIndicesInner = taskIndices.expand(-1);

  // declare local array and load values from global array
  var uLocal1, uLocal2: [taskIndices] real;
  uLocal1 = u[taskIndices];

  // write initial conditions to ghosts
  if tid != 0        then ghosts[RIGHT, tid-1].writeEF(uLocal1[taskIndicesInner.low]);
  if tid != nTasks-1 then ghosts[LEFT, tid+1].writeEF(uLocal1[taskIndicesInner.high]);

  for 1..nt {
    // load values from ghost cells into local array's borders
    if tid != 0        then uLocal1[taskIndices.low] = ghosts[LEFT, tid].readFE();
    if tid != nTasks-1 then uLocal1[taskIndices.high] = ghosts[RIGHT, tid].readFE();

    // run kernel computation
    foreach i in taskIndicesInner do
      uLocal2[i] = uLocal1[i] + nu * dt / dx**2 *
                (uLocal1[i-1] - 2 * uLocal1[i] + uLocal1[i+1]);

    // write results to ghost cells
    if tid != 0        then ghosts[RIGHT, tid-1].writeEF(uLocal2[taskIndicesInner.low]);
    if tid != nTasks-1 then ghosts[LEFT, tid+1].writeEF(uLocal2[taskIndicesInner.high]);

    uLocal1 <=> uLocal2;
  }

  // store results in the global array
  u[taskIndices] = uLocal1;
}

// start timing and comm diagnostics
t.start();
startVerboseComm();

// run the simulation across tasks
coforall (loc, lid) in zip(Locales, 0..) do on loc {
  var ghosts : [0..1, 0..<nTasksPerLoc] sync real;

  coforall tid in 0..<nTasksPerLoc do work(tid + lid * nTasksPerLoc, ghosts);
}

// stop timing and comm diagnostics
stopVerboseComm();
t.stop();

// ---- print final results ------
const mean = (+ reduce u) / u.size,
      stdDev = sqrt((+ reduce (u - mean)**2) / u.size);

writeln("mean: ", mean, " stdDev: ", stdDev);
writeln("elapsed time: ", t.elapsed(), " seconds");
