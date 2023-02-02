# chpl_dwt_example

This is an example of a very simple discrete wavelet transform ([DWT](https://en.wikipedia.org/wiki/Discrete_wavelet_transform)) in [Chapel](https://chapel-lang.org/).

The repo specifically for this code can be found [here](https://github.com/jeremiah-corrado/chpl_dwt_example)

This code uses a 1D 2-element [Haar Wavelet](https://en.wikipedia.org/wiki/Haar_wavelet) to decompose an ECG signal (data courtesy of this [blog post](http://paulbourke.net/dataformats/holter/)).

There are two versions of the same code in this repo:

1. `wavelet.chpl` - meant to look more syntactically similar to Python (it does not use type annotations)
2. `wavelet_typed.chpl` - uses some of Chapel's more advanced type-annotation and formal-intent features (more details in the ppt slides)

## To Compile

With [Chapel installed](https://chapel-lang.org/docs/usingchapel/QUICKSTART.html), run the following in a terminal:

```
chpl wavelet.chpl
```

or

```
chpl wavelet_typed.chpl
```

This will produce a binary with the same name as the source file.

## To Run

Make sure you have Python3 installed with matplotlib, and run the following:

```
./wavelet
```

or 

```
./wavelet_typed
```

A plot of the decomposed ECG signal should appear in the adjacent `results` directory.

You can also add an optional flag to control the number of DWT levels:

```
./wavelet --nLevels=4
```
