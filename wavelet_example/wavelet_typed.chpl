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
proc haarWavelet1D(x: [?d] ?t, n: int) : [d] t
    where d.rank == 1 && isNumericType(t)
{
    assert(2**log2(d.size) == d.size, "array size must be a power of 2");

    var output : [d] t;
    hwRec(x, output, d.size, d.size / 2**n);
    return output;
}

// recursive helper for 'haarWavelet1D'
proc hwRec(const signal, ref output, fmax: int, fstop: int) {
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
proc haarHP(x: [?d] ?t): [d] t {
    var y : [d] t = x;
    forall i in d#d.size-1 do y[i] -= x[i+1];
    return y;
}

// haar 2-element low-pass filter
proc haarLP(x: [?d] ?t): [d] t {
    var y : [d] t = x;
    forall i in d#d.size-1 do y[i] += x[i+1];
    return y;
}

// down-sample by a factor of 2
proc downSample2(x: [?d] ?t) {
    var y : [{d.first..(d.last/2)}] t;
    y = x[d by 2];
    return y;
}
