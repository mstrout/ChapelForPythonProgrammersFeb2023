// diffusion.chpl

/*
   This heat diffusion example (solves a partial differential equation PDE) is setup to take
   advantage of multithreading, but not multiple nodes.  It can be run on multiple nodes by
   setting the number of locales/nodes to something greater than 1 (-nl 4), however, all the
   data will be on the zeroth locale and therefore the overhead of accessing nonlocal data may
   mean distributed parallelism isn't worth it.

   usage on puma/ocelote:
     chpl diffusion.chpl
     ./diffusion -nl 1

   usage on laptop with docker:
     docker pull docker.io/chapel/chapel-gasnet // only have to do this once, but it takes a few minutes

     docker run --rm -v "$PWD":/myapp -w /myapp chapel/chapel-gasnet chpl diffusion.chpl
     docker run --rm -v "$PWD":/myapp -w /myapp chapel/chapel-gasnet ./diffusion -nl 1

     // something else to try
     // FIXME: need a space of reasonable configurations from Jeremiah, also read blog post to see
     // if some are already discussed in there
     docker run --rm -v "$PWD":/myapp -w /myapp chapel/chapel-gasnet ./hello6-taskpar-dist -nl 4 --tasksPerLocale=3

  Slightly modified from PR 19, hpc-chapel-blog/content/posts/bns2/code/nsStep7.chpl
*/


use IO.FormattedIO;

// setup simulation parameters
config const xLen : real = 2,
             yLen : real = 2,
             nx = 31,
             ny = 31,
             nt = 50,
             sigma = 0.25,
             nu = 0.05;

const dx : real = xLen / (nx - 1),
      dy : real = yLen / (ny - 1),
      dt : real = sigma * dx * dy / nu;

// define 2D domain and subdomain
const dom = {0..<nx, 0..<ny};
const domInner : subdomain(dom) = dom.expand(-1);

// define initial conditions
var u : [dom] real = 1;
u[
    (0.5 / dx):int..<(1.0 / dx + 1):int,
    (0.5 / dy):int..<(1.0 / dy + 1):int
] = 2;

// run finite difference computation
var un = u;
for n in 0..#nt {
    u <=> un;
    forall (i, j) in domInner {
        u[i, j] = un[i, j] +
                nu * dt / dy**2 *
                    (un[i-1, j] - 2 * un[i, j] + un[i+1, j]) +
                nu * dt / dx**2 *
                    (un[i, j-1] - 2 * un[i, j] + un[i, j+1]);
    }
}

// compute the standard deviation of 'u'
var mean = (+ reduce u) / u.size;
var std_dev = (+ reduce (u - mean)**2)**(0.5) / u.size;
writef("Final std(u): %.6dr\n", std_dev);

