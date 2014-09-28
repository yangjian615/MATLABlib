function [dt] = sample_rate(t, istart, istop)
    %
    % Calculate the sampling rate.
    %
    
    if nargin == 1
        istart = 1;
        istop = length(t);
    end
    
    dt = (t(istop) - t(istart)) / length(t(istart:istop));
end