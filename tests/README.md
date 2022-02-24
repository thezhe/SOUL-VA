
# Octave Examples
The following sections explain the outputs placed in `results/` after running `test.(bat/sh)` on different `VA::HighLevel` effects (instantiated in `effects.soul`). 

## Parameters
Each effect is tested with approximately the most aliasing-prone parameter values within the valid set of parameter values. This does NOT mean that the plugin will be alias-free (up to -60dB) for all input signal.parameter combinations; nonetheless, this is still an ambitious goal and ensures that aliasing is virtually inaudible under all circumstances. Below are the parameter values in the order of the Processor's instance declarations.

- TheExpressor: 0, 1, 30, 0 , -20, 20, 0.5, 0, 18, 1, 0, 100

### Example Effect 1: `TheDummy`
The system is trivial (and linear) and simply passes signals through unmodified. Notice how the step response input is actually a pulse signal with values 0.5 and 0.25 so that the test can measure overshoot (up towards 1) and undershoot (down towards -1). The DC IO plot is the same as the decibel mapping of a dynamic range compressor with a ratio of 1 and SinRamp IO plot shows what the system would look like as a waveshaper (may not always be a function). 
![Dummy2](https://user-images.githubusercontent.com/42720670/143499549-a8484fe7-bb55-4c24-8242-aa6dd5be6b1c.png)  
![Dummy1](https://user-images.githubusercontent.com/42720670/143499553-e699e725-ad35-413c-9378-3121313d5d49.png)  
### Example Effect 2: `TheBass` (nonlinearity = 200)
The system is significantly nonlinear and all outputs show some sort of nontrivial filtering. While the 'Magnitude Response' only applies to linear systems, its plot accurately predicts that `TheBass` tends to boost bass frequencies. In addition, the internal DC blocker filter corresponds to the high-pass effect at 5 Hz. Consequently, the 'DC IO Plot' does not contain any meaningful information for this effect.
![200_0](https://user-images.githubusercontent.com/42720670/147501416-b4dd38a7-3c66-49b3-8b57-07cc84e9f2ea.png)
![200_1](https://user-images.githubusercontent.com/42720670/147501419-4961ac5c-b33e-49fc-822b-9c117b886c2c.png)
### Example Effect 3: `TheBass` (nonlinearity = 500)
The system is nontrivial, but does not meet the standards of this library. Not all aliasing components are less than -60 dB because they are visible in 'SinSweep Spectrogram (BW)'. Partials that are not parallel to any harmonics/inharmonics, nor low enough in frequency to be residual DC noise appear on the figure -- these are the aliasing components above -60 dB.
![500_0](https://user-images.githubusercontent.com/42720670/147501429-f1b6f600-2b86-40c1-a913-f888c2f9ef35.png)
![500_1](https://user-images.githubusercontent.com/42720670/147501430-67f85641-2030-4946-bb75-9630ddbed1b7.png)
 