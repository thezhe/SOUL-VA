function testMain(fs)
  %% testMain
  % 
  % A script that tests 'main.soulpatch' using a set of inputs (see 'Input-generating functions' section)
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
  function genInputs(fs)
    %% genInputs
    %
    % Generate test inputs
    % 
    % Endpoints:
    % - fs: sampling rate
    % - outputs: .wav files
    %
    % Notes:
    % - All files are lossless .wav, 24-bit, and normalized to 0.5  
    %%
    
    mkdir('inputs');

    genBSin('inputs/BSin.wav', fs);
    gendBRamp('inputs/dBRamp.wav', fs);
    genImpulse('inputs/Impulse.wav', fs);
    genPulse('inputs/Pulse.wav', fs);
    genSin('inputs/Sin.wav', fs);
    genSinRamp('inputs/SinRamp.wav', fs);
  end
  
  function genOutputs(fs)
    %% genOutputs
    %
    % Generate an 'outputs' folder with processed files from 'inputs'
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
  
    pkg load signal;
    
    %% BSin
    isStable('outputs/BSin.wav');

    %% Pulse
    plotSignal('outputs/Pulse.wav', 'Pulse', 1000, 1, [1, 1, 1]); 
    isStable('outputs/Pulse.wav');

    %% dBRamp
    plotWaveshaper('outputs/dBRamp.wav', 'inputs/dBRamp.wav', true, 100, 'dBRamp', 2, [1, 2, 1]);
    isStable('outputs/dBRamp.wav');

    %% SinRamp
    plotWaveshaper('outputs/SinRamp.wav', 'inputs/SinRamp.wav', false, 0, 'SinRamp', 2, [1, 2, 2]);
    isStable('outputs/SinRamp.wav');

    %% Impulse
    plotBode('outputs/Impulse.wav', true, 'Impulse', 3, [3, 1, 1]);
    isStable('outputs/Impulse.wav');

    %% Sin
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
          printf("%s: UNSTABLE\n", file);
        else
          printf("%s: stable\n", file);
        endif
      endfunction
  endfunction
  
  %%==============================================================================
  %% Plotting functions.
  function plotBode(file, phase, title, fig, sp)
    %BodePlot Plot audiofile's magnitude and phase spectrum

    %FFT
    [x, fs] = audioread(file);
    T = 1/fs;
    Ny = fs/2;
    n = length(x);
    df = fs/n;
    f = 0:df:Ny;

    y = fft(x);
    y = y(1:(n/2)+1);
    if (~phase)
      y = y/n;
    end
    y(2:end-1) = y(2:end-1)*2;

    figure(fig, 'units', 'normalized', 'position', [0.1 0.1 0.8 0.8]);

    %Magnitude
    mag = gainTodB(abs(y));
    if (phase)
    idx = mag < -0.5;
    else
    idx = mag > -95 ;
    end

    subplot(sp(1), sp(2), sp(3));
    hold on
    set(gca,'xscale','log');

    if (phase)
      xlim([20, 20000]);
      ylim([-60, 0]);
    end
    scatter(f(idx), mag(idx), 10, "filled");
    hold off
    xlabel('frequency (Hz)');
    ylabel('magnitude (dB)');

    if (phase)
    %Phase

    p = angle(y);
    idx = (abs(p) > 0.25);
    subplot(sp(1), sp(2), sp(3)+1);
    hold on
    xlim([20, 20000]);
    semilogx(f(idx), p(idx), 'LineWidth', 2);
    hold off
    xlabel('frequency (Hz)');
    ylabel('phase (radians)');
    end

  endfunction

  function plotSignal(file, ttl, res, fig, sp)
    %% plotSignal
    %
    % Plot a signal from an audio file
    %%

    [y, fs] = audioread(file);
    info = audioinfo(file);
    T = info.Duration/(length(y)-1);
    y = downsample(y, fs/res);
    t = 0:info.Duration/(res-1):info.Duration;

    figure(fig, 'units', 'normalized', 'position', [0.1 0.1 0.8 0.8]);
    subplot(sp(1), sp(2), sp(3));
    plot(t, y, 'LineWidth', 2);
    title(['\fontsize{60}' ttl]);
    xlabel('\fontsize{30}t (seconds)');
    ylabel('\fontsize{30}amplitude');
  endfunction

  function plotWaveshaper(file2, file1, dB, res, title, fig, sp)
    %% plotWaveshaper
    %
    % Plot samples of file2 vs file1
    %%

    %boiler plate
    [y, fs] = audioread(file2);
    [x, ~] = audioread(file1);

    if (dB)
      y = gainTodB(y); 
      x = gainTodB(x); 
    end

    figure(fig, 'units', 'normalized', 'position', [0.1 0.1 0.8 0.8]);

    subplot(sp(1), sp(2), sp(3));

    if (res>1)
      Q = floor(fs/res);
      x = downsample(x, Q);
      y = downsample(y, Q);
    end

    scatter(x, y, 3, 'filled');

    if(dB)
      xlabel('input (dB)');
      ylabel('output (dB)');
    else
      xlabel('input');
      ylabel('output');
    end
  endfunction

  %%==============================================================================
  %% Input-generating functions.
  function genBSin(file, fs)
    %% genBSin
    %
    % Generate (0.5/6)*sin baised by (2.5/6)*cos with frequencies 2kHz and 18kHz
    %
    % Notes:
    % - Length: 0.25 second
    % - Test: system stability
    % - See Fig. 4 in https://dafx2019.bcu.ac.uk/papers/DAFx2019_paper_3.pdf
    %%

    n = 0:ceil((fs-1)/4);

    A1 = 0.5/6;
    A2 = 2.5/6;

    wd1 = pi*4000/fs;
    wd2 = pi*36000/fs;

    y = A1*sin(wd1*n) + A2*cos(wd2*n);

    audiowrite(file, y, fs, 'BitsPerSample', 24);
  endfunction

  function gendBRamp(file, fs)
    %% gendBRamp
    %
    % Generate ramp on the dB scale
    %
    % Notes:
    % - Length: 2 seconds
    % - Tests: decibel mapping, stability
    %%

    y = dBtoGain(linspace(-60, 0, 2*fs));

    audiowrite(file, y, fs, 'BitsPerSample', 24);
  endfunction 

  function genImpulse(file, fs)  
    %% genImpulse
    %
    % Generate an impulse
    %
    % Notes:
    % - Length: 1 second
    % - Tests: impulse response, frequency response, stability
    %%

    y = [0.5, zeros(1, fs-1)];

    audiowrite(file, y, fs, 'BitsPerSample', 24);
  endfunction

  function genPulse(file, fs)
    %% genImpulse
    %
    % Generate a pulse
    % 
    % Notes:
    % - Length: 1 second
    % - Tests: step response, attack/release response, stability
    %%

    N = ceil(0.5*fs);

    y = zeros(1, N*2);

    y(1:N) = 0.5;
    y(N + 1:end) = 0.25;

    audiowrite(file, y, fs, 'BitsPerSample', 24);
  endfunction

  function genSin(file, fs)
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

    audiowrite(file, y, fs, 'BitsPerSample', 24);
  endfunction
  
  function genSinRamp(file, fs)
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

    audiowrite(file, y, fs, 'BitsPerSample', 24);
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
endfunction