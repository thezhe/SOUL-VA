# The SOUL Virtual Analog Library
[SOUL-VA](https://github.com/thezhe/SOUL-VA) is a collection of analog-inspired audio effects. Unlike other libraries, this project achieves [analytical](https://math.stackexchange.com/questions/935405/what-s-the-difference-between-analytical-and-numerical-approaches-to-problems) solutions and a strict -80dB peak amplitude limit for aliasing artifacts. 

## Contents
- ***VA.soul*** - single-file library
- ***main.soul*** - define connections for effect testing
- ***testMain.m*** - [Octave](https://www.gnu.org/software/octave/index) script that runs test cases on connected effects
- ***soul.json*** - optional [VSCode snippets](https://code.visualstudio.com/docs/editor/userdefinedsnippets)

## Background Knowledge (in order of relevance)
1. [SOUL language guide](https://github.com/soul-lang/SOUL/blob/master/docs/SOUL_Language.md)
2. [soul::filters](https://github.com/soul-lang/SOUL/blob/master/source/soul_library/soul_library_filters.soul)
3. [The Art of VA Filter Design](https://www.kvraudio.com/forum/viewtopic.php?t=350246) (through Chapter 6)
4. [Antiderivative Antialiasing for Memoryless Nonlinearities](https://acris.aalto.fi/ws/portalfiles/portal/27135145/ELEC_bilbao_et_al_antiderivative_antialiasing_IEEESPL.pdf)

## Example: testMain.m on a trivial ***main.soul***
![Pulse](https://user-images.githubusercontent.com/42720670/134750716-e842f0a8-5329-417c-a848-25f1c27f6ba9.png)
![IO](https://user-images.githubusercontent.com/42720670/134750715-c0b01c69-a387-46f8-a178-3460fb64d75b.png)
![Bode](https://user-images.githubusercontent.com/42720670/134750714-80c45c04-65fb-4ab0-8757-d2d346345f54.png)
![Sweep](https://user-images.githubusercontent.com/42720670/134750877-431ce4a0-81c2-4be5-a508-155aa602543a.png)
