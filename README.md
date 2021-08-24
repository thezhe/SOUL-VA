
# SOUL Virtual Analog Library
*VA.soul* is a collection of novel analog-inspired effects optimized for accuracy and efficiency; each effect (in release versions) meets or exceeds the following criterion when used with recommended settings (fs >= 44.1kHz and bit-depth >= 24 bits; see code comments for effect-specific settings):
- available as an easy-to-use 'Processor' in 'VA::HighLevel'
- -100dB peak level of aliasing artifacts
- Frequency warping is equivalent to a filter running @ fs = 88.2kHz
- non-iterative and SIMD optimized using the latest stable release of [SOUL](https://github.com/soul-lang/SOUL)

## Contents
- *VA.soul* - single-file library
- *main.soul* and *main.soulpatch* - library test bench; use *main.soul* to connect Processor instances from *VA.soul*
- *testMain.m* - [Octave](https://www.gnu.org/software/octave/index) script for running test cases on *main.soulpatch*
- *soul.json* - [VSCode](https://github.com/Microsoft/vscode) snippets used in creating *VA.soul*; see the [VSCode docs](https://code.visualstudio.com/docs/editor/userdefinedsnippets) for help with adding the snippets

## Example: testMain(44100)
Running this command with unmodified *main.soul* and *main.soulpatch* files should pass test signals through unchanged and produce these plots:
![Pulse](https://user-images.githubusercontent.com/42720670/129260847-08ae00e7-a749-4b68-9ca4-5907637cdd17.png)
![dBRampSinRamp](https://user-images.githubusercontent.com/42720670/129260840-b48cffc3-1b7f-4f6a-9de4-2b68e3cf8e0c.png)
![ImpulseSin](https://user-images.githubusercontent.com/42720670/129260843-f8e6d77c-5b68-4c2a-9a76-e3fad24f2987.png)
