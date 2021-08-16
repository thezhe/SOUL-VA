
# SOUL Virtual Analog Library
*VA.[soul](https://github.com/soul-lang/SOUL)* is a collection of novel analog-inspired effects optimized for accuracy (anti-aliasing and minimal frequency warping) and efficiency (non-iterative SIMD algorithms). Each effect is packaged in an easy-to-use Processor in VA::HighLevel.

## Contents
- *VA.soul* - single-file library
- *main.soul* and *main.soulpatch* - library test bench; use *main.soul* to connect Processor instances from *VA.soul*
- *testMain.m* - [Octave](https://www.gnu.org/software/octave/index) script for running test cases on *main.soulpatch*

## Example: testMain(44100)
Running this command with unmodified *main.soul* and *main.soulpatch* files should pass test signals through unchanged and produce these plots:
![Pulse](https://user-images.githubusercontent.com/42720670/129260847-08ae00e7-a749-4b68-9ca4-5907637cdd17.png)
![dBRampSinRamp](https://user-images.githubusercontent.com/42720670/129260840-b48cffc3-1b7f-4f6a-9de4-2b68e3cf8e0c.png)
![ImpulseSin](https://user-images.githubusercontent.com/42720670/129260843-f8e6d77c-5b68-4c2a-9a76-e3fad24f2987.png)
