import Time.stopwatch,
       BlockDist.Block,
       Collectives.barrier;

use CommDiagnostics;
config param runCommDiag = false;

config const xLen = 2.0,    // length of the grid in x
             yLen = 2.0,    // length of the grid in y
             nx = 31,       // number of grid points in x
             ny = 31,       // number of grid points in y
             nt = 50,       // number of time steps
             sigma = 0.25,  // stability parameter
             nu = 0.05;     // viscosity

const dx : real = xLen / (nx - 1),       // grid spacing in x
      dy : real = yLen / (ny - 1),       // grid spacing in y
      dt : real = sigma * dx * dy / nu;  // time step size

// define block distributed array
const indices = {0..<nx, 0..<ny},
      indicesInner = indices.expand(-1),
      INDICES = indices dmapped Block(indicesInner);
var u: [INDICES] real;

// apply initial conditions
u = 1.0;
u[
  (0.5 / dx):int..<(1.0 / dx + 1):int,
  (0.5 / dy):int..<(1.0 / dy + 1):int
] = 2;

// set up array of ghost vectors over same locale distribution as 'u'
var ghostVecs: [u.targetLocales().domain] [0..<4] GhostVec;

param L = 0, R = 1, T = 2, B = 3;
const tidXMax = u.targetLocales().dim(0).high - 1,
      tidYMax = u.targetLocales().dim(1).high - 1;

// set up barrier and timer
var b = new barrier(numLocales),
    t = new stopwatch();
t.start();

if runCommDiag then startVerboseComm();

// execute the FD compuation with one task per locale
coforall (loc, (i, j)) in zip(u.targetLocales(), u.targetLocales().domain) do on loc {
  // initialize ghost vectors
  for param edge in 0..<4 {
    param xy = if edge < 2 then 1 else 0;
    ghostVecs[i, j][edge] = new GhostVec(u.localSubdomain().dim(xy).expand(1));
  }

  // synchronize across tasks
  b.barrier();

  // run the portion of the FD computation owned by this task
  work(i, j);
}

if runCommDiag then stopVerboseComm();

t.stop();
writeln("elapsed time: ", t.elapsed(), " seconds");

proc work(tidX: int, tidY: int) {
  // declare two local sub-arrays with room to store neighboring locale's edges
  const localIndices = u.localSubdomain(here),
        localIndicesBuffered = localIndices.expand(1);

  var uLocal1, uLocal2: [localIndicesBuffered] real;

  // populate first local array with initial conditions from global array
  uLocal1[localIndices] = u[localIndices];

  // convenient constants for indexing into edges of local array
  const LL = localIndicesBuffered.dim(0).low,
        RR = localIndicesBuffered.dim(0).high,
        BB = localIndicesBuffered.dim(1).low,
        TT = localIndicesBuffered.dim(1).high;

  // preliminarily populate ghost regions for neighboring locales
  if tidX > 0       then ghostVecs[tidX-1, tidY][R].v = uLocal1[LL+1, ..];
  if tidX < tidXMax then ghostVecs[tidX+1, tidY][L].v = uLocal1[RR-1, ..];
  if tidY > 0       then ghostVecs[tidX, tidY-1][B].v = uLocal1[.., TT-1];
  if tidY < tidYMax then ghostVecs[tidX, tidY+1][T].v = uLocal1[.., BB+1];

  b.barrier();

  // run FD computation
  for 1..nt {
    // populate local edges from ghost regions
    if tidX > 0       then uLocal1[LL, ..] = ghostVecs[tidX, tidY][L].v;
    if tidX < tidXMax then uLocal1[RR, ..] = ghostVecs[tidX, tidY][R].v;
    if tidY > 0       then uLocal1[.., TT] = ghostVecs[tidX, tidY][T].v;
    if tidY < tidYMax then uLocal1[.., BB] = ghostVecs[tidX, tidY][B].v;

    // compute the FD kernel in parallel
    forall (i, j) in localIndices {
      uLocal2[i, j] = uLocal1[i, j] +
              nu * dt / dy**2 *
                (uLocal1[i-1, j] - 2 * uLocal1[i, j] + uLocal1[i+1, j]) +
              nu * dt / dx**2 *
                (uLocal1[i, j-1] - 2 * uLocal1[i, j] + uLocal1[i, j+1]);
    }

    // populate ghost regions for neighboring locales
    if tidX > 0       then ghostVecs[tidX-1, tidY][R].v = uLocal2[LL+1, ..];
    if tidX < tidXMax then ghostVecs[tidX+1, tidY][L].v = uLocal2[RR-1, ..];
    if tidY > 0       then ghostVecs[tidX, tidY-1][B].v = uLocal2[.., TT-1];
    if tidY < tidYMax then ghostVecs[tidX, tidY+1][T].v = uLocal2[.., BB+1];

    // synchronize with other tasks
    b.barrier();

    // swap arrays
    uLocal1 <=> uLocal2;
  }

  // store results back in global array
  u[localIndices] = uLocal1[localIndices];
}

record GhostVec {
  var d: domain(1);
  var v: [d] real;

  proc init() do this.d = {0..0};
  proc init(r: range(int, boundKind.both, strideKind.one)) do
    this.d = {r};
}