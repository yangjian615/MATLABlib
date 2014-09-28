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
function [B_out, t_out] = MrC_SCM_Calibrate(B_scm, t_scm, sc, NFFT)

    % Data is stored as bits with 2^16 bits of precision and the 
    % first 2^15 bits being negative values. Convert to base 10.
    %   - 2^15 = 32768
    %   - 2^16 = 65536
    B_tmp = single( 10 .* (double(B_scm) - 32767) ./ 65535);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load Transfer Functions %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    trasnf_dir         = '/Users/argall/Documents/Work/Programs/Magnetic Merging/Data/Transfer_Functions/';
    [tranferFn, freqs] = MrC_SCM_TransferFn(num2str(sc), trasnf_dir, 'Hbr');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Prep for FFT            %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Frequency and time parameters
    %   - Sampling period
    %   - Frequency resolution
    %   - Nyquist frequency
    %   - Frequencies (+1 is for the DC component)
    dt = mode( diff( MrDatenumToSSM( t_scm ) ) );
    df = 1 / (dt * NFFT);
    fN = 1 / (2 * dt);
    f  = fN * linspace(0, 1, NFFT/2+1);

    % Interpolate the transfer function
    %   - Should this really be NFFT-1?
    %       * There is no 0Hz calibration point in the transfer function. It is
    %         added manually.
    transfX = MrC_SCM_Interp_TransferFn(tranferFn(:,1), freqs, NFFT, df);
    transfY = MrC_SCM_Interp_TransferFn(tranferFn(:,2), freqs, NFFT, df);
    transfZ = MrC_SCM_Interp_TransferFn(tranferFn(:,3), freqs, NFFT, df);

    % Calibrate until end of dataset
    B_out  = zeros(size(B_tmp));
    nPts   = length(B_tmp(:, 1));
    istart = 1;
    istop  = istart + NFFT - 1;

    % Amplitude Correction Factor
    %   - So that SCM reports amplitudes similar to FGM.
    switch sc
        case 1
            B_tmp = 1.240 * B_tmp;
        case 2
            B_tmp = 1.073 * B_tmp;
        case 3
            B_tmp = 1.073 * B_tmp;
        case 4
            B_tmp = 1.080 * B_tmp;
        otherwise
            error('SC must be an integer {1 | 2 | 3 | 4}');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Fourier Transform       %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    while istop < nPts
        % Fourier transform
        B_f = fft(B_tmp(istart:istop, :), [], 1);

        % Apply the transfer function
        B_f(:, 1) = B_f(:, 1) ./ transfX;
        B_f(:, 2) = B_f(:, 2) ./ transfY;
        B_f(:, 3) = B_f(:, 3) ./ transfZ;

        % Inverse transform
        B_out(istart:istop, :) = ifft(B_f, [], 1);

        % Move to next interval
        istart = istop + 1;
        istop  = istart + NFFT - 1;
    end

    % Output arrays
    t_out = t_scm(1:istart-1);
    B_out = B_out(1:istart-1, :);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Rotate into FGM Frame   %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Angle of rotation into FGM frame
    %   Must rotate clockwise (negative angle)
    switch sc
        case 1
            theta = -53.0 * pi/180;
        case 2
            theta = -52.5 * pi/180;
        case 3
            theta = -51.8 * pi/180;
        case 4
            %  angle has not been determined for C4
            theta = -52.5 * pi/180;
    end
    
    % Rotation matrix to FGM frame
    rotmat = [ cos(theta) sin(theta) 0; ...
              -sin(theta) cos(theta) 0; ...
                   0          0      1];
    
    % Transform coordinate systems
    %   - B_out is Nx3
    %   - Rotation matrix is 3x3
    %   - "*" is the inner product
    %  => Must reverse order of multiplication and transpose rotmat.
    B_out = B_out * rotmat';
    
    % Orient as with FSR data
    %   Bx -> 2
    %   By -> 3
    %   Bz -> 1 (Spin Axis)
    B_out = B_out(:,[3,1,2]);
end