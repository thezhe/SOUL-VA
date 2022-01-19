%%  GNU GPLv3 License
  %
  %    Copyright (C) 2021  Zhe Deng 
  %    TheZheDeng@gmail.com
  %
  %    This program is free software: you can redistribute it and/or modify
  %    it under the terms of the GNU General Public License as published by
  %    the Free Software Foundation, either version 3 of the License, or
  %    (at your option) any later version.
  %
  %    This program is distributed in the hope that it will be useful,
  %    but WITHOUT ANY WARRANTY; without even the implied warranty of
  %    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  %    GNU General Public License for more details.
  %
  %    You should have received a copy of the GNU General Public License
  %    along with this program.  If not, see <https://www.gnu.org/licenses/>.
  %%


%% testEffect.m (https://github.com/thezhe/SOUL-VA)
  %
  % Run test cases on 'effect.soulpatch'
  %
  % Requirements:
  % - The SOUL CLI (soul.exe) must be part of the system PATH
  %
  % Arguments:
  % - Fs:  sampling rate; only values in the range [44100, 96000] are officially supported
  %
  % Outputs:
  % - Graphs of test cases 
  % - logs in terminal
  % - Generated .wav files (lossless, 24-bit, 'Fs' sampling rate)
  %
  % Other useful info:
  % - See 'Inputs' section for more info on each test case
  % - Experiencing issues? Try deleting 'inputs/' and 'output/' or restarting Octave
  %%

function testEffect(Fs)
%%==============================================================================
%% Main Script

  %signals package is required
  pkg load signal;  

  %timestamp
  timestamp = strftime ("%Y-%m-%d %H:%M:%S", localtime (time ()));
  printf('\n++++++++++++++++++++++++++++++++++++++++\n');
  printf(['testEffect(' num2str(Fs) '), ' timestamp '\n']);
  printf('++++++++++++++++++++++++++++++++++++++++\n');

  %render '/inputs'
  persistent frequency = 0;
  persistent testEffectTime = 0;
  [testEffectInfo, ~, ~] = stat('testEffect.m');

  if (~isfolder('inputs') || testEffectInfo.mtime ~= testEffectTime || Fs ~= frequency)
    genInputs();
  end

  %render '/outputs'
  persistent vaTime = 0;
  persistent effectTime = 0;
  persistent effectPatchTime = 0;
  [vaInfo, ~, ~] = stat('../include/VA.soul');
  [effectInfo, ~, ~] = stat('effect.soul');
  [effectPatchInfo, ~, ~] = stat('effect.soulpatch');

  if (vaInfo.mtime ~= vaTime || effectInfo.mtime ~= effectTime || effectPatchInfo.mtime ~= effectPatchTime || testEffectInfo.mtime ~= testEffectTime || ~isfolder('TestTrackOutputs'))
    genTestTrackOutputs();
  endif

  if (vaInfo.mtime ~= vaTime || effectInfo.mtime ~= effectTime || effectPatchInfo.mtime ~= effectPatchTime || testEffectInfo.mtime ~= testEffectTime || ~isfolder('outputs') || Fs ~= frequency)
    vaTime = vaInfo.mtime;
    effectTime = effectInfo.mtime;
    effectPatchTime = effectPatchInfo.mtime;
    testEffectTime = testEffectInfo.mtime;
    frequency = Fs;

    genOutputs();
  endif

  %plot results using '/inputs' and '/outputs'
  plotIO();

  printf('\n');
%%==============================================================================
%% High-Level
  function genInputs()
    %%  Generate test inputs in 'inputs/'
    %
    % All inputs normalized to 0.5 except except for 'dBRamp.wav'
    %%

    mkdir('inputs');

    genPulse();
    gendBRamp();
    genSinRamp();
    genImpulse();
    genSinSweep();
    genBSin();
    genSin1k();
    genZerosSin1k();
  endfunction
  
  function genOutputs()
    %%  Generate 'outputs/' by passing 'inputs/' thru 'effect.soulpatch'

    mkdir ('outputs');

    printf('===========================================================================\n');
    printf('Generating ''outputs/''\n');
    printf('===========================================================================\n');

    in = glob('inputs/*.wav');
    for i=1:numel(in)
      [~, name, ~] = fileparts (in{i});
      renderSoul (['outputs/', name, '.wav'], in{i})
    endfor
  endfunction

  function genTestTrackOutputs()
    %%  Generate 'TestTrackOutputs/' by passing 'TestTrackInputs/' thru 'effect.soulpatch'

    mkdir ('TestTrackOutputs');

    printf('===========================================================================\n');
    printf('Generating ''TestTrackOutputs/''\n');
    printf('===========================================================================\n');

    in = glob('TestTrackInputs/*.wav');
    for i=1:numel(in)
      [~, name, ~] = fileparts (in{i});
      renderSoul (['TestTrackOutputs/', name, '.wav'], in{i})
    endfor
  endfunction
  
  function plotIO()
    %%  Plot results using '/inputs' and '/outputs'

    printf('===========================================================================\n');
    printf('testEffect.m logs\n');
    printf('===========================================================================\n');

    grid off

    plotSignal('outputs/Pulse.wav', 'Step Response', 2, [2, 3, 1]); 
    plotWaveshaper('outputs/dBRamp.wav', 'inputs/dBRamp.wav', true, 100, 'DC IO Plot', 2, [2, 3, 2]);
    plotWaveshaper('outputs/SinRamp.wav', 'inputs/SinRamp.wav', false, 0, 'SinRamp IO Plot', 2, [2, 3, 3]);
    plotBode('outputs/Impulse.wav', 'Impulse', 2, [2, 3, 4]);
    plotVectorscope('outputs/SinSweep.wav', 'SinSweep Vectorscope', 2, [2, 3, 6]);
    plotSpec('outputs/SinSweep.wav', true, 'SinSweep Spectrogram (BW)', 1, [1, 1, 1]);

    isStable('outputs/Pulse.wav');
    isStable('outputs/Impulse.wav');
    isStable('outputs/SinRamp.wav');
    isStable('outputs/SinSweep.wav');
    isStable('outputs/BSin.wav');
    isStable('outputs/Sin1k.wav');
    isStable('outputs/ZerosSin1k.wav');

    TTout = glob('TestTrackOutputs/*.wav');
    for i=1:numel(TTout)
      isStable (TTout{i})
    endfor
    
    gainDiff ('outputs/SinSweep.wav'); 
    
    function isStable(file)
      %%  Print a warning if any samples > 0.99 or < 0.01

      [y, ~] = audioread(file);
      
      if (any(abs(y) > 0.99))
        printf("%s: Output is unstable or increases peak level to clipping.\n", file);
      endif

      if (max(y) < 0.01)
        printf("%s: Output is very quite or slient.\n", file);
      endif 
    endfunction

    function gainDiff (file2)
      %% Use with 'outputs/SinSweep.wav' to find makeup gain such that the max output amplitude is 0dB across all sweeped frequencies
      %  In practice the makeup gain is usually more than the estimated value.
      [y, ~] = audioread(file2);

      dBDiff = gainTodB (max(max(y)) / 0.5); #input is normalized to 0.5

      printf("Estimated required makeup gain: %.1f dB.\n", -dBDiff);
    endfunction
  endfunction
  
%%==============================================================================
%% Inputs
  function genBSin()
    %%  Generate (0.5/6)*sin + (2.5/6)*cos with frequencies 2kHz and 18kHz
    %
    % Notes:
    % - 0.5 normalized
    % - Test: stability
    % - Length: 0.25 second
    % - See Fig. 4 in https://dafx2019.bcu.ac.uk/papers/DAFx2019_paper_3.pdf
    %%

    n = (0:ceil((Fs-1)/4)).';

    A1 = 0.5/6;
    A2 = 2.5/6;

    wd1 = pi*4000/Fs;
    wd2 = pi*36000/Fs;

    y = A1 * sin(wd1*n) + A2 * cos(wd2*n);

    audiowrite('inputs/BSin.wav', [y, y], Fs, 'BitsPerSample', 24);
  endfunction

  function gendBRamp()
    %% Generate a linear ramp on the dB scale from -60 dB to 0 dB 
    %
    % Notes:
    % - 0.5 normalized
    % - Tests: decibel input/output mapping for dc signals ('outputs/dBRamp.wav' vs 'input/dBRamp.wav' waveshaper plot a.k.a 'DC IO Plot')
    % - Length: 2 seconds
    %%

    y = dBtoGain(linspace(-60, 0, 2*Fs)).';

    audiowrite('inputs/dBRamp.wav', [y, y], Fs, 'BitsPerSample', 24);
  endfunction 

  function genImpulse()  
    %% Generate an impulse with amplitude 0.5
    %
    % Notes:
    % - 0.5 normalized
    % - Tests: frequency response ('outputs/Impulse.wav' Bode plot a.k.a. 'Magnitude/Phase Response'), stability
    % - Length: 1 second
    %%

    y = [0.5; zeros(Fs-1, 1)];

    audiowrite('inputs/Impulse.wav', [y, y], Fs, 'BitsPerSample', 24);
  endfunction

  function genPulse()
    %% Generate a pulse signal with value 0.5 and 0.25 for the first and second halves
    % 
    % Notes:
    % - 0.5 normalized
    % - Tests: step response and attack/release response ('outputs/Pulse.wav' signal plot a.k.a. 'Step Response'), stability
    % - Length: 1 second
    %%

    y = zeros(Fs, 1);

    y(1:(end/2)) = 0.5;
    y((end/2 + 1):end) = 0.25;

    audiowrite('inputs/Pulse.wav', [y, y], Fs, 'BitsPerSample', 24);
  endfunction

  function genSinSweep()
    %% Generate a sin sweep from 20 to 20kHz
    % 
    % Notes:
    % - 0.5 normalized
    % Tests: harmonic/inharmonic distortion and aliasing ('outputs/SinSweep.wav' spectrogram), estimated makeup gain, stability
    % Length: 10 seconds
    %%

    len = 10;

    t = (0:1/Fs:(len - 1/ Fs)).';

    y = 0.5 * chirp (t, 0, len, 20000);
    
    audiowrite('inputs/SinSweep.wav', [y, y], Fs, 'BitsPerSample', 24);
  endfunction
  
  function genSinRamp()
    %% Generate a sin that fades in linearly
    % 
    % Notes:
    % - 0.5 normalized
    % - Length: 0.025 seconds
    % - Tests: hysteresis in the input output plot ('outputs/SinRamp.wav' vs 'inputs/SinRamp.wav' waveshaper plot a.k.a. 'SinRamp IO Plot'), stability
    %%

    nMax = ceil(0.025*Fs)-1;
    n = (0:nMax).';

    A = (0:0.5/nMax:0.5).';

    wd = pi*880/Fs;

    y = A.*sin(wd*n);

    audiowrite('inputs/SinRamp.wav', [y, y], Fs, 'BitsPerSample', 24);
  endfunction

  function genSin1k()
    %% Generate a 1kHz sin
    % 
    % Notes:
    % - 0.5 normalized
    % - Length: 1 second
    % - Tests: stability
    %%

    n = (0:ceil(Fs-1)).';

    wd = pi*2000/Fs;

    y = 0.5 * sin (wd*n);

    audiowrite('inputs/Sin1k.wav', [y, y], Fs, 'BitsPerSample', 24);
  endfunction

  function genZerosSin1k()
    %% Generate 0.5 seconds of zeros followed by 0.5 seconds of Sin1k
    % 
    % Notes:
    % - 0.5 normalized
    % - Length: 1 second
    % - Tests: stability
    %%

    half = ceil((Fs-1)/2);

    n = (0:half).';

    y = zeros (2*half, 1);

    wd = pi*2000/Fs;

    y(half:end) = 0.5 * sin (wd * n);

    audiowrite('inputs/ZerosSin1k.wav', [y, y], Fs, 'BitsPerSample', 24);

  endfunction
  
%%==============================================================================
%% Plotting

  function plotBode(file, ttl, fig, sp)
    %% Plot magnitude (dB) and phase (radians) responses of an impulse response
    %
    % Notes:
    % - 'file': audio file path
    % - 'ttl': title
    % - 'fig' - figure number
    % - 'sp' - three element array to set the subplot
    %%

    %FFT
    [x, fs] = audioread(file);
    n = length(x);
    df = fs/n;
    f = 0:df:(fs/2);
    y = fft(x);
    y = y(1:(n/2)+1, :) * 2;  

    %magnitude
    mag = gainTodB(abs(y));

    printf('DC magnitude response: %s dB\n', num2str(mag(1)));

    mag = mag(2:length(mag), :);
    fmag = f(2:end);
    [fmagR1, magR1] = reducePlot(fmag, mag(:, 1), 0.0001);
    [fmagR2, magR2] = reducePlot(fmag, mag(:, 2), 0.0001);
    
    figure(fig, 'units', 'normalized', 'position', [0.1 0.1 0.8 0.8]);
    subplot(sp(1), sp(2), sp(3));
    hold on 
      set(gca,'xscale','log');
      set(gca, "linewidth", 1, "fontsize", 16)

      title('\fontsize{20}Magnitude Response');
      xlabel('\fontsize{16}frequency (Hz)');
      ylabel('\fontsize{16}magnitude (dB)');

      plot(fmagR1, magR1, 'LineWidth', 1.5);
      plot(fmagR2, magR2, 'LineWidth', 1.5);
      xlim([fmag(1), 20000]);
      ylim([-40, 6]);
    hold off

    %phase
    p = angle(y);
    dc = sprintf('%.1f', p (1));
    ny = sprintf('%.1f', p (end));

    p = p(2:length(p), :);
    fp = f(2:end);
    [fpR1, pR1] = reducePlot(fp, p(:, 1), 0.0001);
    [fpR2, pR2] = reducePlot(fp, p(:, 2), 0.0001);

    subplot(sp(1), sp(2), sp(3)+1);
    hold on
      set(gca,'xscale','log');
      set(gca, "linewidth", 1, "fontsize", 16);
      title(['\fontsize{20}Phase Response']);
      xlabel('\fontsize{16}frequency (Hz)');
      ylabel('\fontsize{16}phase (rad)');
      xlim([fp(1), 20000]);
      ylim([-pi, pi]);
      
      plot(fpR1, pR1, 'LineWidth', 1.5);
      plot(fpR2, pR2, 'LineWidth', 1.5);
    hold off
  endfunction

  function plotSpec(file, binary, ttl, fig, sp)
    %%  Plot a spectrogram of a file

    [x, fs] = audioread(file);

    n = floor (1024 * (fs/44100));
    win = blackman(n);
    [S0, f, t] = specgram (x(:,1), n, fs, win, 8);
    [S1, ~, ~] = specgram (x(:,2), n, fs, win, 8);

    %bandlimit and normalize
    S0 = abs(S0);
    S1 = abs(S1);
    idx = (S0 > S1);
    S1(idx) = 0;
    S0(!idx) = 0;
    S = S0 + S1;
    S = S/(max(max(S)));
    
    %Black and white binary image
    if (binary)
      S(abs(S) > 0.001) = 1;
    endif

    %clamp to [-60, 0dB]
    S(abs(S)<0.001) = 0.001;
    
    %spectogram
    figure(fig, 'units', 'normalized', 'position', [0.1 0.1 0.8 0.8]);
    subplot(sp(1), sp(2), sp(3));
    hold on
      imagesc (t, f, gainTodB(S));
      colormap (1-gray);
      ylim([0, 20000]);
      xlim([0, 10]);
      set(gca, "fontsize", 16);
      title(['\fontsize{20}' ttl]);
      ylabel('\fontsize{16}frequency (Hz)');
      xlabel('\fontsize{16}time (s)');
    hold off
  endfunction

  function plotSignal(file, ttl, fig, sp)
    %% Plot a signal from an audio file

    [y, fs] = audioread(file);
    info = audioinfo(file);
    t = 0:1/fs:info.Duration-(1/fs);

    [tR1, yR1] = reducePlot(t, y(:, 1), 0.0001);
    [tR2, yR2] = reducePlot(t, y(:, 2), 0.0001);

    figure(fig, 'units', 'normalized', 'position', [0.1 0.1 0.8 0.8]);
    subplot(sp(1), sp(2), sp(3));    
    hold on
      set(gca, "linewidth", 1, "fontsize", 16);
      title(['\fontsize{20}' ttl]);
      xlabel('\fontsize{16}t (seconds)');
      ylabel('\fontsize{16}amplitude');

      plot(tR1, yR1, 'LineWidth', 1.5);
      plot(tR2, yR2, 'LineWidth', 1.5);
      ylim([-1, 1]);
    hold off
  endfunction

  function plotWaveshaper(file2, file1, dB, res, ttl, fig, sp)
    %% Plot samples of file2 vs file1
    %
    % Notes:
    % - 'dB': Set to true to make axes dB scale
    % - 'res': Set number of points to plot (decimate the signal); set to 0 to plot all points
    %%

    [y, fs] = audioread(file2);
    [x, ~] = audioread(file1);

    if (dB)
      y = gainTodB(y); 
      x = gainTodB(x); 
    end

    if (res>1)
      Q = floor(fs/res);
      last = length(x)-mod(length(x), Q);
      x = x(1:Q:last, :);
      y = y(1:Q:last, :);
    end

    figure(fig, 'units', 'normalized', 'position', [0.1 0.1 0.8 0.8]);
    subplot(sp(1), sp(2), sp(3));
    hold on;
      set(gca, "linewidth", 1, "fontsize", 16)
      title(['\fontsize{20}' ttl]);
      if(dB)
        xlabel('\fontsize{16}input (dB)');
        ylabel('\fontsize{16}output (dB)');
        xlim([-60, 0]);
        ylim([-60, 0]);
      else
        xlabel('\fontsize{16}input');
        ylabel('\fontsize{16}output');
        xlim([-0.5, 0.5]);
        ylim([-1, 1]);
      end

      scatter(x(:, 2), y(:, 2), 1, 'filled');
      scatter(x(:, 1), y(:, 1), 1, 'filled');
    hold off
  endfunction

  function plotVectorscope(file, ttl, fig, sp)
    %% Plot a vector scope from a stereo file 
      % See: https://www.rtw.com/en/blog/focus-the-vectorscope.html

    [y, fs] = audioread(file);

    figure(fig, 'units', 'normalized', 'position', [0.1 0.1 0.8 0.8]);
    subplot(sp(1), sp(2), sp(3));
    hold on;
      set(gca, "linewidth", 1, "fontsize", 16)
      title(['\fontsize{20}' ttl]);

      xlabel('\fontsize{16}R');
      ylabel('\fontsize{16}L');
      xlim([-1, 1]);
      ylim([-1, 1]);

      plot (y(:, 2), y(:, 1), 'LineWidth', 0.5);
      camroll (45);
    hold off

     
  endfunction

%%==============================================================================
%% Utility

  function renderSoul(target_file, source_audio_file, fs)
    system(['soul render --output=' target_file ' --input=' source_audio_file ' --rate=' num2str(audioinfo(source_audio_file).SampleRate) ' --bitdepth=' num2str(audioinfo(source_audio_file).BitsPerSample) ' effect.soulpatch']); 
  endfunction

  function y = gainTodB(x)
    y = 20.*log10(x);
    y(y<-100) = -100;
  endfunction

  function y = dBtoGain(x)
    x(x<-100) = -100;
    y = 10.^(x/20);
  endfunction

  function [xR, yR] = reducePlot(x, y, thrdy)
    %% Reduce the points to plot by setting a threshold for dy
    %
    % Notes:
    % - First and last elements are always plotted
    % - Points with abs(dy) > thrdy and points 1 sample before these points are plotted
    %
    % Example:
    %   x = 0:5;
    %   y = [0; 0; 1; 0; 0; 0];
    %   [xR, yR] = reducePlot(x, y, 0.1)
    %   xR = 
    %     0 1 2 3 5 
    %   yR =
    %     0 
    %     0
    %     1
    %     0
    %     0
    %%

    dy = y(2:end) - y(1:end-1);
    dy = abs(dy) > thrdy;
    dy = [1; dy(1:end)];
    dy(1:end-1) = dy(1:end-1) + dy(2:end);
    dy(end) = 1;
    dy(dy>1) = 1;
    idx = logical(dy);

    xR = x(idx);
    yR = y(idx);
  endfunction

endfunction
