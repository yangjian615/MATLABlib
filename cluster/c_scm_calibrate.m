%**************************************************************************
% NAME:
%       MrC_Interp_TransferFn
%
% PURPOSE:
%   Interpolate the transfer function.
%
%   NOTE:
%       Frequencies outside the original frequency range of the transfer
%       function interpolate to NaN values. These should be set to 0 or
%       Inf, depending on whether the transfer function is applied to the
%       signal FFT via multiplication or division, respectively.
%
%       Here, it is assumed that the spectra is multiplied by the transfer
%       function, so 0 is used.
%
% CALLING SEQUENCE:
%   comp = MrC_Interp_TransferFn(filename);
%       Interpolate the transfer function (also called the compensate array
%       because it compensates the uncalibrated counts for not being in
%       physical units).
%
% :Params:
%       TRANSF:     in, required, type=double complex
%                   Amplitude and phase of transfer function at known
%                       frequencies.
%       F:          in, required, type=double array
%                   Frequencies at which the values of the transfer
%                       function are known.
%       N:          in, required, type=integer
%                   Number of frequencies contained in the output array.
%                       This number must be even.
%       DF:         in, required, type=double
%                   Frequency interval between spectral bins of the output
%                       array.
%
% :Returns:
%   DATENUM:        Datenum corresponding to `EPOCH`.
%
%**************************************************************************
%function [comp] = MrC_Calibrate_SCM(scm_data, sc)

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
sc   = '1';
NFFT = 2^13;


%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read SCM Data           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% File name
data_dir = '/Users/argall/Documents/Work/Data/Cluster/20050125_142500_163500';
scm_file = fullfile(data_dir, 'C1_CP_STA_DWF_HBR__20050125_142500_20050125_163500_V080123.cdf');

% Read Data
tname     = 'Time__C1_CP_STA_DWF_HBR';
bname     = 'B_vec_xyz_Instrument__C1_CP_STA_DWF_HBR';
temp_data = cdfread(scm_file, ...
                   'CombineRecords', true, ...
                   'Variables', {tname, bname}, ...
                   'ConvertEpochToDatenum', true);

% Data is stored as bits with 2^16 bits of precision and the 
% first 2^15 bits being negative values. Convert to base 10.
%   - 2^15 = 32768
%   - 2^16 = 65536
t_scm = temp_data{1};
B_scm = single( 10 .* (double(temp_data{2}) - 32767) ./ 65535);
clear temp_data

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load Transfer Functions %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
trasnf_dir         = '/Users/argall/Documents/Work/Programs/Magnetic Merging/Data/Transfer_Functions/';
[tranferFn, freqs] = MrC_SCM_TransferFn(sc, trasnf_dir, 'Hbr');

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prep for FFT            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Frequency and time parameters
%   - Sampling period
%   - Frequency resolution
%   - Nyquist frequency
%   - Frequencies
dt = mode( diff( MrDatenumToSSM( t_scm ) ) );
df = 1 / (dt * NFFT);
fN = 1 / (2 * dt);
f  = fN * linspace(0, 1, NFFT/2+1);

% Interpolate the transfer function
%   - Should this really be NFFT-1?
%       * There is no 0Hz calibration point in the transfer function. It is
%         added manually.
transfX = MrC_Interp_TransferFn(tranferFn(:,1), freqs, NFFT, df);
transfY = MrC_Interp_TransferFn(tranferFn(:,2), freqs, NFFT, df);
transfZ = MrC_Interp_TransferFn(tranferFn(:,3), freqs, NFFT, df);

% Calibrate until end of dataset
B_out  = zeros(size(B_scm));
nPts   = length(B_scm(:, 1));
istart = 1;
istop  = istart + NFFT - 1;

% Amplitude Correction Factor
%   - So that SCM reports amplitudes similar to FGM.
switch str2num(sc)
    case 1
        B_scm = 1.24  * B_scm;
    case 2
        B_scm = 1.073 * B_scm;
    case 3
        B_scm = 1.073 * B_scm;
    case 4
        B_scm = 1.08  * B_scm;
    otherwise
        error('SC must be an integer {1 | 2 | 3 | 4}');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fourier Transform       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
while istop < nPts
    % Fourier transform
    B_f = fft(B_scm(istart:istop, :), [], 1);
    
    %
    % TODO:
    %   1. Rotate to FGM coordinate system
    %   2. Splice in DC component from FGM
    %   3. Despin
    %
    
    % Apply the transfer function
    B_f(:, 1) = B_f(:, 1) ./ transfX;
    B_f(:, 2) = B_f(:, 2) ./ transfY;
    B_f(:, 3) = B_f(:, 3) ./ transfZ;
    
    % Untranform
    B_out(istart:istop, :) = ifft(B_f, [], 1);
    
    % Move to next interval
    istart = istop + 1;
    istop  = istart + NFFT - 1;
end

t_out = t_scm(1:istart-1);
B_out = B_out(1:istart-1, :);
clear scm_data B_f transferFn freqs transfX transfY transfZ f


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display Time-Series Results %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Bx
subplot(3, 1, 1)
plot(t_out, B_out(:, 1));

%By
subplot(3, 1, 2)
plot(t_out, B_out(:, 2));

%Bz
subplot(3, 1, 3)
plot(t_out, B_out(:, 2));



%===========================================%
% Compare Frequency-Domain Results with FGM %
%===========================================%

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read FGM Data           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
fgm_file = fullfile(data_dir, 'C1_CP_FGM_FULL__20050125_142500_20050125_163500_V070906.cdf');
tname    = 'time_tags__C1_CP_FGM_FULL';
bname    = 'B_vec_xyz_gse__C1_CP_FGM_FULL';
fgm_data = cdfread(fgm_file, ...
                   'CombineRecords', true, ...
                   'Variables', {tname, bname}, ...
                   'ConvertEpochToDatenum', true);
t_fgm = fgm_data{1};
B_fgm = double(fgm_data{2});
clear fgm_data

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read FGM Data           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% FGM Sampling rate
dt_fgm = mode( diff( MrDatenumToSSM( t_fgm ) ) );

% Number of points per FFT
multiplier = 8;
[N_scm, N_fgm] = rat(dt_fgm / dt);
N_fgm = multiplier * N_fgm;
N_scm = multiplier * N_scm;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Spectrograms            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create a spectrogram
[s,f,t,p] = spectrogram(B_fgm(:,1), N_fgm, N_fgm/2, N_fgm, 1/dt_fgm);
[S,F,T,P] = spectrogram(B_out(:,1), N_scm, N_scm/2, N_scm, 1/dt);

xrange = [min([t T]), max([t T])];

% FGM Spectrogram
figure
subplot(2,1,1)
surf(t,f,10*log10(p),'edgecolor','none')
axis tight, view(0,90)
xlabel 'Time (s)', ylabel 'Frequency (Hz)', title 'B(x) FGM'
xlim(xrange);
crange = caxis;

% FGM Colorbar
colorbar('location', 'EastOutside');

% SCM Spectrogram
subplot(2,1,2)
surf(T,F,10*log10(P),'edgecolor','none')
axis tight, view(0,90)
xlabel 'Time (s)'
ylabel 'Frequency (Hz)'
title 'B(x) SCM'
xlim(xrange)
ylim([0, max(f)])
caxis(crange);

% SCM Colorbar
colorbar('location', 'EastOutside');


%end