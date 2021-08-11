function testMain(fs)
  %% testMain
  % 
  % A script that tests 'main.soulpatch' using a set of inputs
  % 
  % Notes:
  % - All .wav files are lossless, 24-bit, and have a sampling rate of 'fs' 
  % - Plots show results of test cases (see 'Input-generating functions' section)
  %%
    
  %%==============================================================================
  %% The 'testMain' script.

  if (~isfolder('inputs'))
    genInputs(fs);
  end

  persistent main_time = 0;
  [info, ~, ~] = stat('main.soul');

  if (info.mtime ~= main_time || ~isfolder('outputs'))
    main_time = info.mtime;
    genOutputs(fs);
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
  
  function genOutputs(fs)
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
  
    isStable('outputs/BSin.wav');
    plotSignal('outputs/Pulse.wav', 'Pulse', 1000, 1, [1, 1, 1]); 
    isStable('outputs/Pulse.wav');
    plotWaveshaper('outputs/dBRamp.wav', 'inputs/dBRamp.wav', true, 100, 'dBRamp', 2, [1, 2, 1]);
    isStable('outputs/dBRamp.wav');
    plotWaveshaper('outputs/SinRamp.wav', 'inputs/SinRamp.wav', false, 0, 'SinRamp', 2, [1, 2, 2]);
    isStable('outputs/SinRamp.wav');
    plotBode('outputs/Impulse.wav', true, 'Impulse', 3, [3, 1, 1]);
    isStable('outputs/Impulse.wav');
    plotBode('outputs/Sin.wav', false, 'Sin', 3, [3, 1, 3]);
    isStable('outputs/Sin.wav');

      function isStable(file)
        %%  isStable
        % 
        % Test if an output is stable 
        % 
        % Notes:
        % - Test fails if a sample is >= 1 
        %%  

        [y, ~] = audioread(file);
        
        if (any(abs(y) >= 1))
          printf("%s: This is unstable or is extremely resonant. \n", file);
        endif
      endfunction
  endfunction
  
  %%==============================================================================
  %% Plotting functions.
  function plotBode(file, phase, ttl, fig, sp)
    %% BodePlot 
    % 
    % Plot magnitude (dB) and phase (radians) of a .wav

    %FFT
    [x, fs] = audioread(file);
    T = 1/fs;
    Ny = fs/2;
    n = length(x);
    df = fs/n;
    f = 0:df:Ny;
    f(1) = df-eps;
    y = fft(x);
    y = y(1:(n/2)+1);
    if (~phase)
      y = y/n;
    end
    y = y*2;

    figure(fig, 'units', 'normalized', 'position', [0.1 0.1 0.8 0.8]);

    %Magnitude
    mag = gainTodB(abs(y));
    subplot(sp(1), sp(2), sp(3));
    hold on 
    set(gca,'xscale','log');
    set(gca, "linewidth", 1, "fontsize", 14)
    grid on;
    if (phase)
      xlim([f(1), 20000]);
    else
      xlim([f(1), f(end)]);
    end
    [fR, magR] = reducePlot(f, mag, 1);
    plot(fR, magR, 'LineWidth', 2);
    hold off
    title(['\fontsize{30}' ttl]);
    xlabel('\fontsize{20}frequency (Hz)');
    ylabel('\fontsize{20}magnitude (dB)');

    %phase
    if (phase)
      p = angle(y);
      subplot(sp(1), sp(2), sp(3)+1);
      hold on
      set(gca,'xscale','log');
      set(gca, "linewidth", 1, "fontsize", 14)
      title(['\fontsize{30}' ttl]);
      xlabel('\fontsize{20}frequency (Hz)');
      ylabel('\fontsize{20}phase (rads)');
      grid on;
      xlim([f(1), 20000]);

      [fR, pR] = reducePlot(f, p, 0.1);
      plot(fR, pR, 'LineWidth', 2);

      hold off
     
    end
  endfunction

  function plotSignal(file, ttl, res, fig, sp)
    %% plotSignal
    %
    % Plot a signal from an audio file
    %%

    [y, fs] = audioread(file);
    info = audioinfo(file);
    t = 0:1/fs:info.Duration-(1/fs);
    [tR, yR] = reducePlot(t, y, 0.1);


    figure(fig, 'units', 'normalized', 'position', [0.1 0.1 0.8 0.8]);
    subplot(sp(1), sp(2), sp(3));    
    hold on
      set(gca, "linewidth", 1, "fontsize", 14);
      title(['\fontsize{30}' ttl]);
      xlabel('\fontsize{20}t (seconds)');
      ylabel('\fontsize{20}amplitude');
      
      plot(tR, yR, 'LineWidth', 2);
    hold off
  endfunction

  function plotWaveshaper(file2, file1, dB, res, ttl, fig, sp)
    %% plotWaveshaper
    %
    % Plot samples of file2 vs file1
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
      else
        xlabel('\fontsize{20}input');
        ylabel('\fontsize{20}output');
      end
      grid on;

      scatter(x, y, 3, 'filled');
    hold off
  endfunction

  %%==============================================================================
  %% Input-generating functions.
  function genBSin()
    %% genBSin
    %
    % Generate (0.5/6)*sin baised by (2.5/6)*cos with frequencies 2kHz and 18kHz
    %
    % Notes:
    % - Length: 0.25 second
    % - Test: System stability. Test passes if no console warnings are printed.
    % - See Fig. 4 in https://dafx2019.bcu.ac.uk/papers/DAFx2019_paper_3.pdf
    %%

    n = 0:ceil((fs-1)/4);

    A1 = 0.5/6;
    A2 = 2.5/6;

    wd1 = pi*4000/fs;
    wd2 = pi*36000/fs;

    y = A1*sin(wd1*n) + A2*cos(wd2*n);

    audiowrite('inputs/BSin.wav', y, fs, 'BitsPerSample', 24);
  endfunction

  function gendBRamp()
    %% gendBRamp
    %
    % Generate a gradual ramp on the dB scale from -60 dB to 0 dB 
    %
    % Notes:
    % - Length: 2 seconds
    % - Tests: stability, decibel mapping (outputs/dBRamp vs input/dBRamp plot)
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
    % - Length: 1 second
    % - Tests: stability, frequency response (magnitude and phase plots)
    %%

    y = [0.5, zeros(1, fs-1)];

    audiowrite('inputs/Impulse.wav', y, fs, 'BitsPerSample', 24);
  endfunction

  function genPulse()
    %% genImpulse
    %
    % Generate a pulse
    % 
    % Notes:
    % - Length: 1 second
    % - Tests: step response and attack/release response (outputs/Pulse.wav plot), stability
    %%

    N = ceil(0.5*fs);

    y = zeros(1, N*2);

    y(1:N) = 0.5;
    y(N + 1:end) = 0.25;

    audiowrite('inputs/Pulse.wav', y, fs, 'BitsPerSample', 24);
  endfunction

  function genSin()
    %% genSin
    %
    % Generate sin
    % 
    % Notes:
    % Length: 1 second
    % Tests: harmonic/inharmonic distortion, stability
    %%

    n = 0:fs-1;

    wd = pi*36000/fs;

    y = 0.5*sin(wd*n); 

    audiowrite('inputs/Sin.wav', y, fs, 'BitsPerSample', 24);
  endfunction
  
  function genSinRamp()
    %% genSin
    %
    % Generate a sin that fades in linearly
    % 
    % Notes:
    % - Length: 0.025 seconds
    % - Tests: hysteresis mapping, stability
    %%

    nMax = (0.025*fs)-1;
    n = 0:nMax;

    A = 0:0.5/nMax:0.5;

    wd = pi*880/fs;

    y = A.*sin(wd*n);

    audiowrite('inputs/SinRamp.wav', y, fs, 'BitsPerSample', 24);
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