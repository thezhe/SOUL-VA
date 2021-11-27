![SOUL-VA_logo](https://user-images.githubusercontent.com/42720670/143501884-f9a4daac-9460-4312-bacf-4984ef002dc4.png)
# The SOUL Virtual Analog Library
[SOUL-VA](https://github.com/thezhe/SOUL-VA) is a collection of analog-inspired audio effects. Unlike other libraries, this project achieves [analytical](https://math.stackexchange.com/questions/935405/what-s-the-difference-between-analytical-and-numerical-approaches-to-problems) solutions and [a strict -60dB peak amplitude limit for aliasing artifacts](https://github.com/thezhe/SOUL-VA#example-3-onepolec_lan-nonlinearity--300).

**A 1.0.0 Github release will be uploaded once two VA::Highlevel Processors are finished, thoroughly tested, and documented (Approx. December 2021).**

## Background Knowledge
This library considers background knowledge trivial; *SOUL-VA will not re-explain any of the following concepts*:  
### To use the main features (`VA::HighLevel` and `main` namespaces), read:  
1. [SOUL language guide](https://github.com/soul-lang/SOUL/blob/master/docs/SOUL_Language.md)  
2. [soul::filters](https://github.com/soul-lang/SOUL/blob/master/source/soul_library/soul_library_filters.soul)  
### To use the entire library (all namespaces), also read:  
3. [The Art of VA Filter Design](https://www.kvraudio.com/forum/viewtopic.php?t=350246) (through Chapter 6)   
4. [Antiderivative Antialiasing for Memoryless Nonlinearities](https://acris.aalto.fi/ws/portalfiles/portal/27135145/ELEC_bilbao_et_al_antiderivative_antialiasing_IEEESPL.pdf)

## Contents
- `src/VA.soul` - single-file library
- `src/main.soul` - `[[main]]` instance for instantiating `Processors` from VA.soul
- `src/main.soulpatch` - 'includes' and 'links' VA.soul with main.soul
- `tests/testMain.m` - script that runs test cases on main.soulpatch
- `tools/soul.json` - [VSCode snippets](https://code.visualstudio.com/docs/editor/userdefinedsnippets)

## Official Ways to Use SOUL-VA
1. [SOUL Playground](https://soul.dev/lab/)  
Copy VA.soul, main.soul, and main.soulpatch into the editor and click 'Compile'. To enable stereo processing, modify main.soul according to the instructions.
2. [SOUL CLI 1.0.82](https://github.com/soul-lang/SOUL/releases/tag/1.0.82)  
Read the CLI instructions by executing soul.exe in a terminal and use main.soulpatch as the '\<soul file\>'. Stereo processing and higher oversampling rates will not compile using this method.
3.  [Octave 6.3.0](https://www.gnu.org/software/octave/index)   
Include soul.exe in the 'Path' environment variable. Set SOUL-VA as the current working directory in Octave and run `testMain(44100)`. See testMain.m for more info on test cases and usage.

## Contributing
Please post bugs in issues and feature requests in discussions. Bug fixes take priority. Pull requests are not accepted at the moment.

## Octave Examples 
The following sections explain the output after running `testMain (44100)` on different `VA::HighLevel` effects (instantiated in `Processor [[main]]`).
### Example 1: `Dummy`
The system is trivial (and linear) and simply passes signals through unmodified. Notice how the step response is actually a pulse signal with values 0.5 and 0.25 so that the test can measure overshoot and undershoot.
![Dummy2](https://user-images.githubusercontent.com/42720670/143499549-a8484fe7-bb55-4c24-8242-aa6dd5be6b1c.png)  
![Dummy1](https://user-images.githubusercontent.com/42720670/143499553-e699e725-ad35-413c-9378-3121313d5d49.png)  
### Example 2: `OnepoleC_Lan` (nonlinearity = 200)
The system is significantly nonlinear and all outputs show some sort of distortion. While the magnitude response applies only to linear systems, its plot in the output accurately predicts that `OnepoleC_Lan` tends to boost bass frequencies.
![OnepoleC_Lan(200)2](https://user-images.githubusercontent.com/42720670/143499888-6d6bb662-d376-4e94-90f3-c417c346b851.png)  
![OnepoleC_Lan(200)1](https://user-images.githubusercontent.com/42720670/143499897-f637bf2f-9c7f-469a-954f-06ace715cf5c.png)  
### Example 3: `OnepoleC_Lan` (nonlinearity = 500)
The system is significantly nonlinear, but does not meet the standards of this library. Not all aliasing components are less than -60dB as shown by the non-DC inharmonic partials in the bottom right-hand corner in 'SinSweep (BW)'.  
![OnepoleC_Lan(500)2](https://user-images.githubusercontent.com/42720670/143499912-0e513b21-b668-488e-ae87-a767db9aadab.png)  
![OnepoleC_Lan(500)1](https://user-images.githubusercontent.com/42720670/143499917-0621c055-8e9d-4c08-891e-cf0de483885d.png)  

