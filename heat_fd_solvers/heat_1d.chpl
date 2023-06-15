import Time.stopwatch;

// ---- set up simulation parameters ------
// declare configurable parameters with default values
config const xLen = 2.0,    // length of the grid in x
             nx = 31,       // number of grid points in x
             nt = 50,       // number of time steps
             sigma = 0.25,  // stability parameter
             nu = 0.05;     // viscosity

// declare non-configurable parameters
const dx : real = xLen / (nx - 1),       // grid spacing in x
      dt : real = sigma * dx / nu;       // time step size

var t = new stopwatch();

// ---- set up the grid ------
// define a domain and subdomain to describe the grid and its interior
const indices = {0..<nx},
      indicesInner = {1..<nx-1};

// define a 2D array over the above domain
var u : [indices] real;

// set up initial conditions
u = 1.0;
u[(0.5 / dx):int..<(1.0 / dx + 1):int] = 2;

// ---- run the finite difference computation ------
// create a temporary copy of 'u' to store the previous time step
var un = u;

// start timing
t.start();

// iterate for 'nt' time steps
for 1..nt {

  // swap the arrays to prepare for the next time step
  u <=> un;

  // update the solution over the interior of the domain in parallel
  forall i in indicesInner {
    u[i] = un[i] + nu * dt / dx**2 *
                (un[i-1] - 2 * un[i] + un[i+1]);
  }
}

// stop timing
t.stop();

// ---- print final results ------
const mean = (+ reduce u) / u.size,
      stdDev = sqrt((+ reduce (u - mean)**2) / u.size);

writeln("mean: ", mean, " stdDev: ", stdDev);
writeln("elapsed time: ", t.elapsed(), " seconds");
