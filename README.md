# SOUL Virtual Analog Library
***VA.soul*** is a library of analog-inspired audio effects; each effect meets the following criterion:<sup>[1](#f1)</sup>
- available as an easy-to-use *Processor* in *VA::HighLevel*
- -80dB peak level of aliasing artifacts
- non-iterative and SIMD optimized processing using the latest stable release of [SOUL](https://github.com/soul-lang/SOUL)

<sub><a name="f1">1</a>: This is only guaranteed under the following conditions: 1.) sampling rate and bit depth are at least 44.1kHz and 24-bit and 2.) effect-specific instructions are followed</sub>

## Contents<sup>[2](#f2)</sup>
- ***VA.soul*** - single-file library
- ***main.soul***, ***main.soulpatch*** - define connections for effect testing
- ***testMain.m*** - [Octave](https://www.gnu.org/software/octave/index) script that runs test cases on connected effects
- ***soul.json*** - useful library snippets for [VSCode](https://code.visualstudio.com/docs/editor/userdefinedsnippets)

<sub><a name="f2">2</a>: Before starting, developers should understand the key concepts of [the SOUL language guide](https://github.com/soul-lang/SOUL/blob/master/docs/SOUL_Language.md), [soul::filters](https://github.com/soul-lang/SOUL/blob/master/source/soul_library/soul_library_filters.soul), and [The Art of VA Filter Design](https://www.kvraudio.com/forum/viewtopic.php?t=350246) (up through Chapter 6). </sub>

## Example: *testMain(44100)*
Running this command without modifying any files returns the following results:
![Pulse](https://user-images.githubusercontent.com/42720670/134750716-e842f0a8-5329-417c-a848-25f1c27f6ba9.png)
![IO](https://user-images.githubusercontent.com/42720670/134750715-c0b01c69-a387-46f8-a178-3460fb64d75b.png)
![Bode](https://user-images.githubusercontent.com/42720670/134750714-80c45c04-65fb-4ab0-8757-d2d346345f54.png)
![Sweep](https://user-images.githubusercontent.com/42720670/134750877-431ce4a0-81c2-4be5-a508-155aa602543a.png)
