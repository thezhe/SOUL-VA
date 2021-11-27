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


%% testMain.m (https://github.com/thezhe/SOUL-VA)
  %
  % - IMPORTANT: The SOUL CLI (soul.exe) must be part of the system PATH
  % - fs = 44100 highly recommended
  % - All .wav files are lossless, 24-bit, and the sampling rates are 'fs' 
  % - See 'Inputs' section for more info on each test case
  % - Experiencing issues? Try deleting 'inputs/' and 'output/' or restarting Octave 6.3.0
  %%

%% Task List
  %
  % double runs on VA.soul fix
  % verify FFT weights
  % update Inputs descriptions
  % check input output deletion/refresh criteria

function testMain(fs)
%%==============================================================================
%% Main Script

  %signals package is required
  pkg load signal;  

  %render '/inputs'
  if (~isfolder('inputs'))
    genInputs();
  end

  %render '/outputs'
  persistent vaTime = 0;
  persistent mainTime = 0;
  persistent mainPatchTime = 0;
  persistent testMainTime = 0;
  
  [vaInfo, ~, ~] = stat('../include/VA.soul');
  [mainInfo, ~, ~] = stat('../examples/main.soul');
  [mainPatchInfo, ~, ~] = stat('../examples/main.soulpatch');
  [testMainInfo, ~, ~] = stat('testMain.m');

  if (vaInfo.mtime ~= vaTime || mainInfo.mtime ~= mainTime || mainPatchInfo.mtime ~= mainPatchTime || testMainInfo.mtime ~= testMainTime || ~isfolder('outputs'))
    vaTime = vaInfo.mtime;
    mainTime = mainInfo.mtime;
    mainPatchTime = mainPatchInfo.mtime;
    testMainTime = testMainInfo.mtime;

    genOutputs();
  end

  %plot results using '/inputs' and '/outputs'
  plotIO();
  
%%==============================================================================
%% High-Level
  function genInputs()
    %%  Generate test inputs in 'inputs/'
    %
    % All inputs normalized to 0.5 except except for 'dBRamp.wav' and 'SinSweep.wav'
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
    %%  Generate 'outputs/' by passing 'inputs/' thru 'main.soulpatch'

    mkdir('outputs');
    printf('===============================================================\n');
    printf('                          SOUL logs                            \n');
    printf('===============================================================\n');
    renderSoul('outputs/Pulse.wav', 'inputs/Pulse.wav');
    renderSoul('outputs/dBRamp.wav', 'inputs/dBRamp.wav');
    renderSoul('outputs/SinRamp.wav', 'inputs/SinRamp.wav');
    renderSoul('outputs/Impulse.wav', 'inputs/Impulse.wav');
    renderSoul('outputs/SinSweep.wav', 'inputs/SinSweep.wav');
    renderSoul('outputs/Bsin.wav', 'inputs/BSin.wav');
    renderSoul('outputs/Sin1k.wav', 'inputs/Sin1k.wav');
    renderSoul('outputs/ZerosSin1k.wav', 'inputs/ZerosSin1k.wav');

    function renderSoul(target_file, source_audio_file)
      system(['soul render --output=' target_file ' --input=' source_audio_file ' --rate=' num2str(fs) ' --bitdepth=24 ../examples/main.soulpatch']); 
    endfunction
  endfunction
  
  function plotIO()
    %%  Plot results using '/inputs' and '/outputs'
    %
    % Notes:
    % - Shows a warning message if 0.5 normalized inputs exceed 0.9 in the output
    % - The Bode plot is only defined for linear systems
    % - The phase response in the Bode plot may be distorted if the system is oversampled
    %%

    grid off

    plotSignal('outputs/Pulse.wav', 'Step Response', 2, [2, 3, 1]); 
    plotWaveshaper('outputs/dBRamp.wav', 'inputs/dBRamp.wav', true, 100, 'DC IO Plot', 2, [2, 3, 2]);
    plotWaveshaper('outputs/SinRamp.wav', 'inputs/SinRamp.wav', false, 0, 'SinRamp IO Plot', 2, [2, 3, 3]);
    plotBode('outputs/Impulse.wav', 'Impulse', 2, [2, 3, 4]);
    plotSpec('outputs/SinSweep.wav', false, 'SinSweep Spectrogram', 2, [2, 3, 6]);
    plotSpec('outputs/SinSweep.wav', true, 'SinSweep Spectrogram (BW)', 1, [1, 1, 1]);

    printf('===============================================================\n');
    printf('                       testMain.m logs                         \n');
    printf('===============================================================\n');
    isStable('outputs/Pulse.wav');
    isStable('outputs/Impulse.wav');
    isStable('outputs/SinRamp.wav');
    isStable('outputs/SinSweep.wav');
    isStable('outputs/BSin.wav');
    isStable('outputs/Sin1k.wav');
    isStable('outputs/ZerosSin1k.wav');
    
    #the output dB difference is the max gain compensation needed across all frequencies
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
      %% Find max change in peak amplitude (use with SinSweep)
      [y, ~] = audioread(file2);

      dBDiff = gainTodB (max(y) / 0.5); #assume input is normalized to 0.5

      printf("Approximate max output/input peak amplitude change is %.1f dB.\n", dBDiff);
    endfunction
  endfunction
  
%%==============================================================================
%% Inputs
  function genBSin()
    %%  Generate (0.5/6)*sin + (2.5/6)*cos with frequencies 2kHz and 18kHz
    %
    % Notes:
    % - Test: System stability. Test passes if no console warnings are printed.
    % - Length: 0.25 second
    % - See Fig. 4 in https://dafx2019.bcu.ac.uk/papers/DAFx2019_paper_3.pdf
    %%

    n = 0:ceil((fs-1)/4);

    A1 = 0.5/6;
    A2 = 2.5/6;

    wd1 = pi*4000/fs;
    wd2 = pi*36000/fs;

    y = A1 * sin(wd1*n) + A2 * cos(wd2*n);

    audiowrite('inputs/BSin.wav', y, fs, 'BitsPerSample', 24);
  endfunction

  function gendBRamp()
    %% Generate a linear ramp on the dB scale from -60 dB to 0 dB 
    %
    % Notes:
    % - Tests: decibel input/output mapping for dc signals ('outputs/dBRamp.wav' vs 'input/dBRamp.wav' waveshaper plot), stability
    % - Length: 2 seconds
    %%

    y = dBtoGain(linspace(-60, 0, 2*fs));

    audiowrite('inputs/dBRamp.wav', y, fs, 'BitsPerSample', 24);
  endfunction 

  function genImpulse()  
    %% Generate an impulse with amplitude 0.5
    %
    % Notes:
    % - Tests: frequency response ('outputs/Impulse.wav' Bode plot), stability
    % - Length: 1 second
    %%

    y = [0.5, zeros(1, fs-1)];

    audiowrite('inputs/Impulse.wav', y, fs, 'BitsPerSample', 24);
  endfunction

  function genPulse()
    %% Generate a pulse signal with value 0.5 and 0.25 for the first and second halves
    % 
    % Notes:
    % - Tests: step response and attack/release response ('outputs/Pulse.wav' signal plot), stability
    % - Length: 1 second
    %%

    y = zeros(1, fs);

    y(1:(end/2)) = 0.5;
    y((end/2 + 1):end) = 0.25;

    audiowrite('inputs/Pulse.wav', y, fs, 'BitsPerSample', 24);
  endfunction

  function genSinSweep()
    %% Generate a sin sweep from 20 to 20kHz
    % 
    % Notes:
    % Tests: harmonic/inharmonic distortion and aliasing ('outputs/SinSweep.wav' spectrogram), peak amplitude change, stability
    % Length: 10 seconds
    %%

    t = 0:1/fs:10;

    y = 0.5 * chirp(t, 20, 11, 20000);
    
    audiowrite('inputs/SinSweep.wav', y, fs, 'BitsPerSample', 24);
  endfunction
  
  function genSinRamp()
    %% Generate a sin that fades in linearly
    % 
    % Notes:
    % - Length: 0.025 seconds
    % - Tests: hysteresis in the input output plot ('outputs/SinRamp.wav' vs 'inputs/SinRamp.wav' waveshaper plot), stability
    %%

    nMax = ceil(0.025*fs)-1;
    n = 0:nMax;

    A = 0:0.5/nMax:0.5;

    wd = pi*880/fs;

    y = A.*sin(wd*n);

    audiowrite('inputs/SinRamp.wav', y, fs, 'BitsPerSample', 24);
  endfunction

  function genSin1k()
    %% Generate a 1kHz sin
    % 
    % Notes:
    % - Length: 1 second
    % - Tests: stability
    %%

    n = 0:ceil(fs-1);

    wd = pi*2000/fs;

    y = 0.5 * sin (wd*n);

    audiowrite('inputs/Sin1k.wav', y, fs, 'BitsPerSample', 24);
  endfunction

  function genZerosSin1k()
    %% Generate 0.5 seconds of zeros followed by 0.5 seconds of Sin1k
    % 
    % Notes:
    % - Length: 1 second
    % - Tests: stability
    %%

    half = ceil((fs-1)/2);

    n = 0:half;

    y = zeros (1, 2*half);

    wd = pi*2000/fs;

    y(half:end) = 0.5 * sin (wd * n);

    audiowrite('inputs/ZerosSin1k.wav', y, fs, 'BitsPerSample', 24);

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
    y = y(1:(n/2)+1);
    y = y * 2;    

    %magnitude
    mag = gainTodB(abs(y));
    dc = sprintf('%.1f', mag(1));
    ny = sprintf('%.1f', mag(end));
    mag = mag(2:end-1);
    fmag = f(2:end-1);
    [fmagR, magR] = reducePlot(fmag, mag, 0.0001);
    
    figure(fig, 'units', 'normalized', 'position', [0.1 0.1 0.8 0.8]);
    subplot(sp(1), sp(2), sp(3));
    hold on 
      set(gca,'xscale','log');
      set(gca, "linewidth", 1, "fontsize", 16)
      xlim([fmag(1), 20000]);
      title(['\fontsize{20}Magnitude Response']);
      xlabel('\fontsize{16}frequency (Hz)');
      ylabel('\fontsize{16}magnitude (dB)');

      plot(fmagR, magR, 'LineWidth', 1.5);
    hold off

    %phase
    p = angle(y);
    dc = sprintf('%.1f', p (1));
    ny = sprintf('%.1f', p (end));

    p = p(2:end-1);
    fp = f(2:end-1);
    [fpR, pR] = reducePlot(fp, p, 0.0001);

    subplot(sp(1), sp(2), sp(3)+1);
    hold on
      set(gca,'xscale','log');
      set(gca, "linewidth", 1, "fontsize", 16)
      title(['\fontsize{20}Phase Response']);
      xlabel('\fontsize{16}frequency (Hz)');
      ylabel('\fontsize{16}phase (rads)');
      xlim([fp(1), 20000]);
      ylim([-pi, pi]);
      
      plot(fpR, pR, 'LineWidth', 1.5);
    hold off
  endfunction

  function plotSpec(file, binary, ttl, fig, sp)
    %%  Plot a spectrogram of a file

    [x, fs] = audioread(file);

    n = 1024;
    win = blackman(n);
    [S, f, t] = specgram (x, n, fs, win, 8);

    %bandlimit and normalize
    S = S((f>=20 & f <= 20000), :);
    S = abs(S)./(max(max(abs(S))));
    
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
      xlim([0,10]);
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
    [tR, yR] = reducePlot(t, y, 0.0001);

    figure(fig, 'units', 'normalized', 'position', [0.1 0.1 0.8 0.8]);
    subplot(sp(1), sp(2), sp(3));    
    hold on
      set(gca, "linewidth", 1, "fontsize", 16);
      title(['\fontsize{20}' ttl]);
      xlabel('\fontsize{16}t (seconds)');
      ylabel('\fontsize{16}amplitude');

      plot(tR, yR, 'LineWidth', 1.5);
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
      x = x(1:Q:last);
      y = y(1:Q:last);
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
      else
        xlabel('\fontsize{16}input');
        ylabel('\fontsize{16}output');
        xlim([-0.5, 0.5]);
      end

      scatter(x, y, 1, 'filled');
    hold off
  endfunction

%%==============================================================================
%% Utility
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
