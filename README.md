# The SOUL Virtual Analog Library
[SOUL-VA](https://github.com/thezhe/SOUL-VA) is a collection of analog-inspired audio effects. Unlike other libraries, this project achieves [analytical](https://math.stackexchange.com/questions/935405/what-s-the-difference-between-analytical-and-numerical-approaches-to-problems) solutions and a strict -60dB peak amplitude limit for aliasing artifacts.

**A 1.0.0 Github release will be uploaded once two VA::Highlevel Processors are finished, thoroughly tested, and documented (Approx. December 2021).**
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
## Background Knowledge
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
This library considers background knowledge trivial; *do not expect any re-explaination of the following concepts*:  
### To use the main features (`VA::HighLevel` and `main` namespaces), read:  
1. [SOUL language guide](https://github.com/soul-lang/SOUL/blob/master/docs/SOUL_Language.md)  
2. [soul::filters](https://github.com/soul-lang/SOUL/blob/master/source/soul_library/soul_library_filters.soul)  
### To use the entire library (all namespaces), also read:  
3. [The Art of VA Filter Design](https://www.kvraudio.com/forum/viewtopic.php?t=350246) (through Chapter 6)   
4. [Antiderivative Antialiasing for Memoryless Nonlinearities](https://acris.aalto.fi/ws/portalfiles/portal/27135145/ELEC_bilbao_et_al_antiderivative_antialiasing_IEEESPL.pdf)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
## Contents
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
- [***VA.soul***](https://github.com/thezhe/SOUL-VA/blob/main/VA.soul) - single-file library with a `[[main]]` instance called `Processor [[main]]`
- [***testMain.m***](https://github.com/thezhe/SOUL-VA/blob/main/testMain.m) - script that runs test cases on `Processor [[main]]`
- [***soul.json***](https://github.com/thezhe/SOUL-VA/blob/main/soul.json) - [VSCode snippets](https://code.visualstudio.com/docs/editor/userdefinedsnippets)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
## Ways to use SOUL-VA
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
### Reccomended 
1. [SOUL Playground](https://soul.dev/lab/)  
Copy and paste contents of VA.soul into the editor and click 'Compile'. To enable stereo processing, modify `Processor [[main]]` according to the instructions.
2. [SOUL CLI 1.0.82](https://github.com/soul-lang/SOUL/releases/tag/1.0.82)  
Read the CLI instructions by executing soul.exe in a terminal and use VA.soul as the '\<soul file\>'. Stereo processing and higher oversampling rates will not compile using this method.
3.  [Octave 6.3.0](https://www.gnu.org/software/octave/index)   
Include soul.exe in the 'Path' environment variable. Set SOUL-VA as the current working directory in Octave and run `testMain(44100)`. See testMain.m for more info on test cases and usage.
### NOT Reccomended
4. [Tracktion Waveform](https://www.tracktion.com/products/waveform-free)  
As of Waveform 11.5.18, no support for .soulpatch exists. Expect SOUL LLVM JIT instances in older Waveform versions to crash with stereo inputs and VA.soul.
5. [SOUL Patch Loader Plugin](https://github.com/soul-lang/SOUL/blob/master/tools/plugin/Patch_Plugin_README.md)  
#4, but in plugin form.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
## Contributing
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
This repository does not accept pull requests, but posts in 'issues' and 'discussions' are much welcomed. Feedback regarding bugs take priority.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
## Octave Examples 
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
The following sections demonstrate the outputs after running 'testMain (44100)' on different `VA::HighLevel` effects (instantiated in `Processor [[main]]`).

### Example 1: Dummy
The test signals are not modified and the system is linear.

### Example 2: OnepoleC_Lan (nonlinearity = 200)
The system is nonlinear and all outputs show some sort of distortion.

### Example 3: OnepoleC_Lan (nonlinearity = 300)
The system produces audible filtering, but does not meet the standards of this library. Some aliasing components are more than -60dB as shown by the non-DC inharmonic partials in 'SinSweep'.