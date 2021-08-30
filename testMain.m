function testMain(fs)
  %% testMain
  % 
  % A script that tests 'main.soulpatch' using a set of inputs
  % 
  % Notes:
  % - All .wav files are lossless, 24-bit, and have a sampling rate of 'fs' 
  % - Plots show responses to each input (see 'Input-generating functions' section)
  %%
    
  %%==============================================================================
  %% The 'testMain' script.

  if (~isfolder('inputs'))
    genInputs();
  end

  persistent mainTime = 0;
  persistent vaTime = 0;
  [mainInfo, ~, ~] = stat('main.soul');
  [vaInfo, ~, ~] = stat('VA.soul');

  if (mainInfo.mtime ~= mainTime || vaInfo.mtime ~= vaTime || ~isfolder('outputs'))
    mainTime = mainInfo.mtime;
    vaTime = vaInfo.mtime;
    genOutputs();
  end

  plotIO();
  
  %%==============================================================================
  %% Top Level functions.
  function genInputs()
    %% genInputs
    %
    % Notes:
    % - Generates test inputs in 'inputs/'
    % - All inputs normalized to 0.5 except for dBRamp
    %%

    mkdir('inputs');

    genBSin();
    gendBRamp();
    genImpulse();
    genPulse();
    genSin();
    genSinRamp();
  end
  
  function genOutputs()
    %% genOutputs
    %
    % Generate 'outputs/' by passing 'inputs/' thru 'main.soulpatch'
    %%

    mkdir('outputs');

    renderSoul('outputs/Bsin.wav', 'inputs/BSin.wav');
    renderSoul('outputs/Pulse.wav', 'inputs/Pulse.wav');
    renderSoul('outputs/dBRamp.wav', 'inputs/dBRamp.wav');
    renderSoul('outputs/SinRamp.wav', 'inputs/SinRamp.wav');
    renderSoul('outputs/Impulse.wav', 'inputs/Impulse.wav');
    renderSoul('outputs/Sin.wav', 'inputs/Sin.wav');

    function renderSoul(target_file, source_audio_file)
      system(['soul render --output=' target_file ' --input=' source_audio_file ' --rate=' num2str(fs) ' --bitdepth=24 main.soulpatch']); 
    endfunction
  endfunction
  
  function plotIO()
    %% plotIO
    %
    % Plot responses to '/inputs' and check stability of 0.5 normalized inputs
    %
    % Note:
    % - The magnitude and phase responses of 'Impulse.wav' is meaningless if the system is nonlinear
    % - The phase response of 'Impulse.wav' may be distorted if the system is oversampled
    %%

    isStable('outputs/BSin.wav');
    isStable('outputs/Pulse.wav');
    isStable('outputs/Impulse.wav');
    isStable('outputs/Sin.wav');
    isStable('outputs/SinRamp.wav');

    plotSignal('outputs/Pulse.wav', 'Pulse', 1, [1, 1, 1]); 
    plotWaveshaper('outputs/dBRamp.wav', 'inputs/dBRamp.wav', true, 100, 'dBRamp', 2, [1, 2, 1]);
    plotWaveshaper('outputs/SinRamp.wav', 'inputs/SinRamp.wav', false, 0, 'SinRamp', 2, [1, 2, 2]);
    plotBode('outputs/Impulse.wav', true, 'Impulse', 3, [3, 1, 1]);
    plotBode('outputs/Sin.wav', false, 'Sin', 3, [3, 1, 3]);
    
    function isStable(file)
      %%  isStable
      % 
      % Print a warning if any samples > 0.9
      %%  

      [y, ~] = audioread(file);
      
      if (any(abs(y) > 0.9))
        printf("%s: Output is unstable or extremely resonant. \n", file);
      endif
    endfunction
  endfunction
  
  %%==============================================================================
  %% Input-generating functions.
  function genBSin()
    %% genBSin
    %
    % Generate (0.5/6)*sin baised by (2.5/6)*cos with frequencies 2kHz and 18kHz
    %
    % Notes:
    % - Test: System stability. Test passes if no console warnings are printed.
    % - See Fig. 4 in https://dafx2019.bcu.ac.uk/papers/DAFx2019_paper_3.pdf
    % - Length: 0.25 second
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
    %% gendBRamp
    %
    % Generate a gradual linear ramp on the dB scale from -60 dB to 0 dB 
    %
    % Notes:
    % - Tests: decibel mapping ('outputs/dBRamp.wav' vs 'input/dBRamp.wav' waveshaper plot), stability
    % - Length: 2 seconds
    %%

    y = dBtoGain(linspace(-60, 0, 2*fs));

    audiowrite('inputs/dBRamp.wav', y, fs, 'BitsPerSample', 24);
  endfunction 

  function genImpulse()  
    %% genImpulse
    %
    % Generate an impulse with amplitude 0.5
    %
    % Notes:
    % - Tests: frequency response ('outputs/Impulse.wav' Bode plot), stability
    % - Length: 1 second
    %%

    y = [0.5, zeros(1, fs-1)];

    audiowrite('inputs/Impulse.wav', y, fs, 'BitsPerSample', 24);
  endfunction

  function genPulse()
    %% genImpulse
    %
    % Generate a pulse signal with value 0.5 and 0.25 for the first and second halves
    % 
    % Notes:
    % - Tests: step response and attack/release response ('outputs/Pulse.wav' plot), stability
    % - Length: 1 second
    %%

    y = zeros(1, fs);

    y(1:(end/2)) = 0.5;
    y((end/2 + 1):end) = 0.25;

    audiowrite('inputs/Pulse.wav', y, fs, 'BitsPerSample', 24);
  endfunction

  function genSin()
    %% genSin
    %
    % Generate sin with 9kHz frequency
    % 
    % Notes:
    % Tests: harmonic/inharmonic distortion ('outputs/Sin.wav' magnitude response plot), stability
    % Length: 1 second
    %%

    n = 0:fs-1;

    wd = pi*18000/fs;

    y = 0.5*sin(wd*n); 

    audiowrite('inputs/Sin.wav', y, fs, 'BitsPerSample', 24);
  endfunction
  
  function genSinRamp()
    %% genSinRamp
    %
    % Generate a sin that fades in linearly
    % 
    % Notes:
    % - Length: 0.025 seconds
    % - Tests: hysteresis ('outputs/SinRamp.wav' vs 'inputs/SinRamp.wav' waveshaper plot), stability
    %%

    nMax = ceil(0.025*fs)-1;
    n = 0:nMax;

    A = 0:0.5/nMax:0.5;

    wd = pi*880/fs;

    y = A.*sin(wd*n);

    audiowrite('inputs/SinRamp.wav', y, fs, 'BitsPerSample', 24);
  endfunction
  
  %%==============================================================================
  %% Plotting functions.
  function plotBode(file, linear, ttl, fig, sp)
    %% BodePlot 
    % 
    % Plot magnitude (dB) and phase (radians) of an audio file
    %
    % Notes:
    % - 'file': audio file path
    % - 'linear': set to true if system is linear (extra subplot for phase)
    % - 'ttl': title
    % - 'fig' - figure number
    % - 'sp' - three element array to set the subplot
    % - See 'plotIO()' for examples
    %%

    %FFT
    [x, fs] = audioread(file);
    n = length(x);
    df = fs/n;
    f = 0:df:(fs/2);
    y = fft(x);
    y = y(1:(n/2)+1);
    if (~linear)
      y = y/n;
      y(2:end-1) = y(2:end-1)*2;
    else
      y = y * 2;    
    end

    %Magnitude
    mag = gainTodB(abs(y));
    dc = num2str(mag(1));
    ny = num2str(mag(end));
    mag = mag(2:end-1);
    fmag = f(2:end-1);
    [fmagR, magR] = reducePlot(fmag, mag, 0.01);
    
    figure(fig, 'units', 'normalized', 'position', [0.1 0.1 0.8 0.8]);
    subplot(sp(1), sp(2), sp(3));
    hold on 
      set(gca,'xscale','log');
      set(gca, "linewidth", 1, "fontsize", 14)
      if (linear)
        xlim([fmag(1), 20000]);
        ylim([-60, 0]);
      else
        xlim([fmag(1), fmag(end)]);
        ylim([-100, 0]);
      end
      title(['\fontsize{30}' ttl ' (|Y(0)| = ' dc ' dB, |Y(fs/2)| = ' ny ' dB)']);
      xlabel('\fontsize{20}frequency (Hz)');
      ylabel('\fontsize{20}magnitude (dB)');
      grid on;

      plot(fmagR, magR, 'LineWidth', 2);
    hold off

    %linear
    if (linear)
      p = angle(y);
      dc = num2str(p(1));
      ny = num2str(p(end));

      p = p(2:end-1);
      fp = f(2:end-1);
      [fpR, pR] = reducePlot(fp, p, 0.001);

      subplot(sp(1), sp(2), sp(3)+1);
      hold on
        set(gca,'xscale','log');
        set(gca, "linewidth", 1, "fontsize", 14)
        title(['\fontsize{30}' ttl ' (\angle Y(0) = ' dc ' rads, \angle Y(fs/2) = ' ny ' rads)']);
        xlabel('\fontsize{20}frequency (Hz)');
        ylabel('\fontsize{20}linear (rads)');
        xlim([fp(1), 20000]);
        ylim([-pi, pi]);
        grid on;
        
        plot(fpR, pR, 'LineWidth', 2);
      hold off
    end
  endfunction

  function plotSignal(file, ttl, fig, sp)
    %% plotSignal
    %
    % Plot a signal from an audio file
    %
    % Notes: 
    % - See 'plotBode()' for parameter descriptions
    % - See 'plotIO()' for examples
    %%

    [y, fs] = audioread(file);
    info = audioinfo(file);
    t = 0:1/fs:info.Duration-(1/fs);
    [tR, yR] = reducePlot(t, y, 0.01);

    figure(fig, 'units', 'normalized', 'position', [0.1 0.1 0.8 0.8]);
    subplot(sp(1), sp(2), sp(3));    
    hold on
      set(gca, "linewidth", 1, "fontsize", 14);
      ylim([0, 0.75]);
      title(['\fontsize{30}' ttl]);
      xlabel('\fontsize{20}t (seconds)');
      ylabel('\fontsize{20}amplitude');
      grid on;

      plot(tR, yR, 'LineWidth', 2);
    hold off
  endfunction

  function plotWaveshaper(file2, file1, dB, res, ttl, fig, sp)
    %% plotWaveshaper
    %
    % Plot samples of file2 vs file1
    %
    % Notes:
    % - 'dB': Set to true to make axes dB scale
    % - 'res': Set number of points to plot; set to 0 to plot all points
    % - See 'plotBode()' and 'plotSignal()' for other parameter descriptions
    % - See 'plotIO()' for examples
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
      set(gca, "linewidth", 1, "fontsize", 14)
      title(['\fontsize{30}' ttl]);
      if(dB)
        xlabel('\fontsize{20}input (dB)');
        ylabel('\fontsize{20}output (dB)');
        xlim([-60, 0]);
        ylim([-60, 0]);
      else
        xlabel('\fontsize{20}input');
        ylabel('\fontsize{20}output');
        xlim([-1, 1]);
        ylim([-1, 1]);
      end
      grid on;

      scatter(x, y, 3, 'filled');
    hold off
  endfunction

  %%==============================================================================
  %% Utility functions.
  function y = gainTodB(x)
    y = 20.*log10(x);
    y(y<-100) = -100;
  endfunction

  function y = dBtoGain(x)
    x(x<-100) = -100;
    y = 10.^(x/20);
  endfunction

  function [xR, yR] = reducePlot(x, y, thrdy)
    %% reducePlot
    % 
    % Reduce the points to plot by setting a threshold for dy
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