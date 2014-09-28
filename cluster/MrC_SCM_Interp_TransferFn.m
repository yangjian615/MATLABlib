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
function [comp] = MrC_SCM_Interp_TransferFn(transf, f, N, df)
    
    % N must be even
    %   N == # frequencies to compensate
    assert(mod(N, 2) == 0, 'N must be even.');
    
    %
    % The transfer function is created for positive frequencies, as they
    % are the only measurable frequencies. It then has to be duplicated for
    % negative frequencies.
    %
    
    % Desired frequencies where the tranfer function is to be interpolated.
    %   - Note that the minimum frequency is df, not 0.
    %   - Later, an extra element will be added to account for DC.
    pivot = N/2;
    f_out = df * (1:pivot)';
    
    % Interpolate
    %   - The nyquist frequency is a combination of the forward and
    %     backward frequecies (i.e. the absolute value).
    comp        = interp1(f, transf, f_out, 'linear');
    comp(pivot) = abs( comp(pivot) );
    
    %
    % Values outside the initial range of the transfer function are
    % effectively removed (NaNs). Replace NaNs by Inf so that when the
    % transfer function is applied to the signal FFT (via division), the
    % signal amplitude is zero.
    %
    comp(isnan(comp)) = Inf;
    
    %
    % Double the length of the compensate array and fill the back half
    % with a reflection of the front half, taking the complex conjugate to
    % turn the frequencies negative.
    %
    % Add in the DC component. Make it 1, indicating no phase or amplitude
    % correction.
    %
    % When reflecting the array, do not include the DC or Nyquist frequency
    % components.
    %
    comp = [ 1 ; comp ; flipud( conj( comp(1:end-1) ) ) ];
end