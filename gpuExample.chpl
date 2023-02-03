// Example that will run on a GPU or CPU.
// See https://chapel-lang.org/docs/technotes/gpu.html for more information.

use GPUDiagnostics;
startGPUDiagnostics();

var operateOn = if here.gpus.size > 0 then here.gpus else [here,];

// Same code can run on GPU or CPU
coforall loc in operateOn do on loc {
  var A: [1..10] int;
  foreach a in A do a+=1;
  writeln(A);
}

stopGPUDiagnostics();
writeln(getGPUDiagnostics());

