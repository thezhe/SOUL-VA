## PLUG-QA
To run PLUG-QA on an effect, edit the instantiation/connections in ([`effect.soulpatch`](https://github.com/thezhe/SOUL-VA/blob/master/tests/effect.soulpatch)) and then run [test.ps1](https://github.com/thezhe/SOUL-VA/blob/master/scripts/test.ps1)/[test.sh](https://github.com/thezhe/SOUL-VA/blob/master/scripts/test.sh).

### Official aliasing-prone instantiations:
- VA::HighLevel::TheExpressor::Processor (false, 0.1f, 30, 0 , -20, 20, 0.5f, 0, 18, 1, 0, 100)

## Parameter Modulateability
Unless commented as non-modulateable, parameters are tested to be artifact-free (i.e., no clicks or zipper noise) and responsive under modulation by any waveform up through 8 Hz; most parameters can theoretically modulate up to 20 Hz without any noticable problems.
