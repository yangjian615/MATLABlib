function [n_max] = merge_n_max(t, clen, n_shift)
    %
    % Calculate the numer of FFT windows that fit within the sampling period. Default to
    % overlapping by a quarter of the FFT window.
    %
    
    if nargin < 3
        n_shift = clen/4;
    end
    
    % Integer math rounds. It does not truncate. CLEN and N_SHIFT
    % must be singles or doubles
    assert( ~isa(clen,    'int'), 'CLEN must be floating point number.')
    assert( ~isa(n_shift, 'int'), 'N_SHIFT must be floating point number.')

    n_max = floor( (length(t) - clen) / n_shift) + 1;
end