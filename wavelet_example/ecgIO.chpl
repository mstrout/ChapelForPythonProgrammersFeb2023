
use IO;
import Subprocess.spawn;

proc readEcgData(path: string): [] int throws {
    var r = openreader(path),
        lines = r.readAll(bytes),
        arr : [{0..<lines.count(b"\n")}] int;

    for (line, idx) in zip(lines.split(b"\n", ignoreEmpty=true), 0..) {
        arr[idx] = line.partition(b" ")[2] : int;
    }

    return arr;
}

proc plotDwtData(signal, coefficients, n: int) throws {
    writeArray(openwriter("results/signal.txt"), signal);
    writeArray(openwriter("results/coeffs.txt"), coefficients);

    spawn(["python3", "plot.py", n:string]);
}

proc writeArray(writer, x) throws {
    for val in x do writer.write(val, " ");
    writer.writeln();
}
