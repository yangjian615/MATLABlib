function out=powersd(fft,dt)
    %
    %   this function returns the power spectral density of
    %     a fft created by the MATLAB fft function
    %
    %   if dt is the separation of each point in the time domain in secs
    %   the powersd(fft,dt)  returns the power in ( )^2/Hz
    %
    lensiz = length(fft)/2;
    out = (dt/lensiz)*(abs(fft(2:lensiz+1,:)).^2);
    out(lensiz,:) = out(lensiz,:)/2;
end