%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sc         = 1;
directory  = '/Users/argall/Documents/Work/Data/Cluster/20050125_142500_163500';
outdir     = ''; %'/Users/argall/Google Drive/Work/Thesis/argall_PhD_Thesis/Chapters/Chapter_5_MergeTech/Chp5_Figures/';
fsr_file   = fullfile(directory, 'C1_20050125_FSR.mag');
fgm_file   = fullfile(directory, 'C1_CP_FGM_FULL__20050125_142500_20050125_163500_V070906.cdf');
scm_file   = fullfile(directory, 'C1_CP_STA_DWF_HBR__20050125_142500_20050125_163500_V080123.cdf');
quiet_time = '2005-01-25 14:35:45';
multiplier = 64;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read Data                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read FGM data if no quiet time was given (to visualize in GSE).
if strcmp(quiet_time, '')
    tname    = 'time_tags__C1_CP_FGM_FULL';
    bname    = 'B_vec_xyz_gse__C1_CP_FGM_FULL';
    fgm_data = cdfread(fgm_file, ...
                       'CombineRecords', true, ...
                       'Variables', {tname, bname}, ...
                       'ConvertEpochToDatenum', true);

                   
% Read FSR data when comparing power spectra.
else
    fsr_ID   = fopen(fsr_file);
    fgm_data = textscan(fsr_ID, '%f%f%f%f', 'Delimiter', ' ', 'MultipleDelimsAsOne', 1);
    fgm_data = {fgm_data{1} [fgm_data{2} fgm_data{3} fgm_data{4}]};
    fclose(fsr_ID);
end

% Group FGM data
t_fgm = fgm_data{1};
B_fgm = fgm_data{2};
clear fgm_data

% Read SCM Data
tname    = 'Time__C1_CP_STA_DWF_HBR';
bname    = 'B_vec_xyz_Instrument__C1_CP_STA_DWF_HBR';
scm_data = cdfread(scm_file, ...
                   'CombineRecords', true, ...
                   'Variables', {tname, bname}, ...
                   'ConvertEpochToDatenum', true);

% Group SCM data.
t_scm = scm_data{1};
B_scm = scm_data{2};
clear scm_data

%=============================%
% Visualize Time-Series       %
%=============================%

% Pick a quiet interval by looking at the time-series.
if strcmp(quiet_time, '')
    % FGM
    subplot(2, 1, 1);
    plot(fgm_data{1}, fgm_data{2});
    title('FGM Data');
    xlabel('Time (Hours)');
    ylabel('B (nT)');
    xlim( datenum({'2005-01-25 14:30:45' '2005-01-25 14:45:00'}, 'yyyy-mm-dd HH:MM:SS') );
    datetick('x', 'HH:MM:SS', 'keeplimits')
    
    
    % SCM
    subplot(2, 1, 2);
    plot(scm_data{1}, scm_data{2});
    title('SCM Data');
    xlabel('Time (Hours)');
    xlim( datenum({'2005-01-25 14:30:45' '2005-01-25 14:45:00'}, 'yyyy-mm-dd HH:MM:SS') );
    ylabel('B (nT)');
    datetick('x', 'HH:MM:SS', 'keeplimits')
    
    return
end

%=============================%
% FFT of Quiet Interval       %
%=============================%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FFT Parameters              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Convert to seconds since midnight
if strcmp(quiet_time, '')
    ssm_fgm = MrDatenumToSSM( t_fgm );
else
    ssm_fgm = t_fgm * 3600;
end

% Determine the sampling rate
dt_fgm  = mode( diff( ssm_fgm ) );
dt_scm  = mode( diff( MrDatenumToSSM( t_scm ) ) );

% Number of points per FFT
[n, d]     = rat(dt_fgm / dt_scm);
N_fgm      = multiplier * d;
N_scm      = multiplier * n;

% Find the index of the start of the quiet interval
%   FGM time is in number of hours (it is FSR data)
%   SCM time is in MATLAB date number
sHours      = str2double(quiet_time(12:13)) .* 3600 + ...
              str2double(quiet_time(15:16)) .*   60 + ...
              str2double(quiet_time(18:end));
sDatenumber = datenum(quiet_time, 'yyyy-mm-dd HH:MM:SS');
i_fgm       = find(ssm_fgm >= sHours,      1);
i_scm       = find(t_scm   >= sDatenumber, 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calibrate SCM & Spectrogram %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calibrate the search coil instrument
B_scm = MrC_SCM_Calibrate(B_scm, t_scm, sc, N_scm);

% Take the FFT of the quiet interval
fft_fgm = fft(B_fgm(i_fgm:i_fgm+N_fgm-1, :), [], 1);
fft_scm = fft(B_scm(i_scm:i_scm+N_scm-1, :), [], 1);
clear i_fgm t_fgm B_fgm i_scm t_scm B_scm

% Power spectral denstiy
%   Multiply by dt/N to convert to units of power
%   Multiply by two to include power from negative frequencies
psd_fgm             = (dt_fgm / N_fgm) .* abs( fft_fgm(1:N_fgm/2+1, :) ).^2;
psd_scm             = (dt_scm / N_scm) .* abs( fft_scm(1:N_scm/2+1, :) ).^2;
psd_fgm(2:end-1, :) = 2 * psd_fgm(2:end-1, :);
psd_scm(2:end-1, :) = 2 * psd_scm(2:end-1, :);
clear fft_fgm fft_scm

% Frequencies
df_fgm = 1 / (dt_fgm * N_fgm);
df_scm = 1 / (dt_scm * N_scm);
f_fgm  = (1/(2*dt_fgm)) * linspace(0, 1, N_fgm/2+1); %0:df_fgm:(1/(2*dt_fgm));
f_scm  = (1/(2*dt_scm)) * linspace(0, 1, N_scm/2+1);
clear dt_fgm dt_scm N_fgm N_scm

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visualize                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% FGM
subplot(3,1,1)
plot(f_fgm, 10*log10(psd_fgm))
title('Noise floor of FGM');
xlabel('Frequency (Hz)');
ylabel('Power (10*log_{10}(nT^2 / Hz))')
legend({'X', 'Y', 'Z'});

% SCM
subplot(3,1,2)
plot(f_scm, 10*log10(psd_scm))
title('Noise floor of SCM');
xlabel('Frequency (Hz)');
ylabel({'Power', '10*log_{10}(nT^2 / Hz)'});
legend({'X', 'Y', 'Z'});

% X-Component
subplot(3,1,3);
plot(f_fgm, 10*log10(psd_fgm(:,1)), f_scm, 10*log10(psd_scm(:,1)));
xlim([0, max(f_fgm)]);
title('Cross-over frequency');
xlabel('Frequency (Hz)');
ylabel({'Power', '10*log_{10}(nT^2 / Hz)'});

legend({'Y_{fgm}', 'Y_{scm}'});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save Figures                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(outdir, '') == 0
    outfile = fullfile(outdir, 'NoiseFloor');
    print(gcf, '-depsc2', [outfile '.eps']);
    print(gcf, '-dps',    [outfile '.ps']);
    print(gcf, '-dpng',   [outfile '.png']);
    disp(['Saving files to: ', outfile, '.png']);
end

clear f_fgm psd_fgm f_scm psd_scm

