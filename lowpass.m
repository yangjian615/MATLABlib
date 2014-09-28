function [filtered] = lowpass(dt, field, f_cutoff)

    %
    % A lowpass filter. Take the FFT of "field" and set the fourier
    % coefficients above the cut-off frequency, "f_cutoff", to zero.
    %

    clen = length(field(:,1));              % length of the FFT
    df = 1/(dt * clen);                     % frequency bin size
    freqs = df * (0:clen/2);                % FFT frequencies
    i_cutoff = find(freqs <= f_cutoff, 1, 'last');  % index of f_cutoff

    field_fft = fft(field);
    field_fft(i_cutoff+1:clen/2,:) = 0;
    field_fft((clen/2)+1:(clen/2+1)+(clen/2-i_cutoff+1-1),:) = 0;

    filtered = ifft(field_fft);
end