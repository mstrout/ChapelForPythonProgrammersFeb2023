use ecgIO;

config const nLevels = 3;

proc main() {
    // read sample data
    //  (data pulled from: http://paulbourke.net/dataformats/holter/)
    const ecgSamples = try! readEcgData("ecg_samples.txt"),
          lenP2 = 2**(floor(log2(ecgSamples.size)):int);

    // compute 1D DWT
    const ecg_dwt = haarWavelet1D(ecgSamples[0..<lenP2], nLevels);

    // generate a plot of the signal and DWT
    plotDwtData(ecgSamples[0..<lenP2], ecg_dwt, nLevels);
}


// compute an n-level wavelet transform of 'x'
proc haarWavelet1D(x, n) {
    assert(2**log2(x.size) == x.size, "array size must be a power of 2");

    var output : [x.domain] int;
    hwRec(x, output, x.size, x.size / 2**n);
    return output;
}

// recursive helper for 'haarWavelet1D'
proc hwRec(signal, output, fmax, fstop) {
    if fmax == fstop {
        // store the final layer of high-pass coefficients
        output[{0..<fmax}] = signal;
    } else {
        cobegin {
            // compute and store the low-pass coefficients
            output[{fmax/2..<fmax}] = downSample2(haarLP(signal));

            // compute the high-pass coefficients and start the next layer of filtering
            hwRec(downSample2(haarHP(signal)), output, fmax/2, fstop);
        }
    }
}

// haar 2-element high-pass filter
proc haarHP(x) {
    var y : [x.domain] int = x;
    forall i in x.domain#(x.domain.size-1) do y[i] -= x[i+1];
    return y;
}

// haar 2-element low-pass filter
proc haarLP(x) {
    var y : [x.domain] int = x;
    forall i in x.domain#(x.domain.size-1) do y[i] += x[i+1];
    return y;
}

// down-sample by a factor of 2
proc downSample2(x) {
    var y : [{x.domain.first..(x.domain.last/2)}] int;
    y = x[x.domain by 2];
    return y;
}
