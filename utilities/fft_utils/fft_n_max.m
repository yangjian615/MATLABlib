function [n_max] = merge_n_max(t, clen, n_shift)
    %
    % Calculate the numer of FFT windows that fit within the sampling period. Default to
    % overlapping by a quarter of the FFT window.
    %
    
    if nargin < 3
        n_shift = clen/4;
    end

    n_max = floor( (length(t) - clen) / n_shift) + 1;
end