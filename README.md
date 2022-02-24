![SOUL-VA_logo](logo.png)
# The SOUL Virtual Analog Library
[SOUL-VA](https://github.com/thezhe/SOUL-VA) is a collection of analog-inspired audio effects. Unlike other libraries, this project achieves [analytical](https://math.stackexchange.com/questions/935405/what-s-the-difference-between-analytical-and-numerical-approaches-to-problems) solutions and a strict -60dB peak amplitude limit for aliasing artifacts (see `tests/README.md`). Each effect can run at full quality at 44.1kHz without any additional antialiasing measures. In addition, unless marked as non-automatable, parameters are artifact-free (e.g. no clicks) and responsive under user interaction and under modulation by any waveform up through 8 Hz; theoretically they may modulate up to 50Hz without artifacts.

## Background Knowledge
This library considers background knowledge trivial; *SOUL-VA does not re-explain any of the following concepts*:  
### To use the high-level features (`VA::HighLevel` namespace), understand:  
1. [SOUL language guide](https://github.com/soul-lang/SOUL/blob/master/docs/SOUL_Language.md)  
2. [soul::filters](https://github.com/soul-lang/SOUL/blob/master/source/soul_library/soul_library_filters.soul)  
### To use the entire library (all namespaces), also understand:  
3. [The Art of VA Filter Design](https://www.kvraudio.com/forum/viewtopic.php?t=350246) (through Chapter 6)   
4. [Antiderivative Antialiasing for Memoryless Nonlinearities](https://acris.aalto.fi/ws/portalfiles/portal/27135145/ELEC_bilbao_et_al_antiderivative_antialiasing_IEEESPL.pdf)

## Official Ways to Use SOUL-VA
1. [SOUL Playground](https://soul.dev/lab/)  
Copy `include/VA.soul`, `examples/main.soul`, and `examples/main.soulpatch` into the editor. Delete '../include/' on line 13 in main.soulpatch. Click 'Compile' to run in mono mode. To enable stereo processing, modify main.soul according to the instructions.
2. [SOUL CLI 1.0.82](https://github.com/soul-lang/SOUL/releases/tag/1.0.82)  
Read the CLI instructions by executing soul.exe in a terminal and use main.soulpatch as the `<soul file>`. This method does not support stereo processing.
3.  [Octave 6.4.0](https://www.gnu.org/software/octave/download)   
Include soul.exe in the 'Path' environment variable. Set `tests/` as the current working directory in Octave and run `testEffect(44100)`. See `tests/testEffect.m` for more info on test cases and usage.

## Contents
Files in each top-level directory start with a short summary. Users can utilize `VA::HighLevel` using only the `include/` and `examples/` directories.

## Update Policy 
1. The current effect endpoints in `VA::HighLevel` are permanent (excluding major bugs and design revisions), but new endpoints may appear in updates. In other words, effect endpoints are backward compatible, but all other code may change.
2. In release versions, `tests/errors.soulpatch` compiles successfully (i.e. all effects compile on Mac, Windows, and Linux without errors). Furthermore, all effects achieve proper aliasing levels, parameter modulation stability, and stereo compatibility in Octave and SOUL Playground on Windows.

## Contributing
Please post bugs in issues and feature requests in discussions. Bug fixes take priority. Pull requests are not accepted at the moment.

## Plugins Made with SOUL-VA 
[![bluecup](https://user-images.githubusercontent.com/42720670/152609111-888165ed-e27e-4955-a22f-347d2954891c.png)](https://ko-fi.com/thezhe/shop)
[![kvr](https://user-images.githubusercontent.com/42720670/152609112-e1d92040-9d24-41b8-aaff-470976a1b883.png)](https://kvraudio.com/developer/thezhe)
[![p4fimg](https://user-images.githubusercontent.com/42720670/152609108-04d95a63-f082-4fd6-b5b1-447fcca3e88c.jpg)](https://plugins4free.com/dev/814/)
