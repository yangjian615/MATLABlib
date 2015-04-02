function [freqs] = calc_fft_freqs(df, clen)
    %
    % Calculate the frequencies of an FFT interval given the frequency bin separation, df,
    % and the number of points in the FFT window, clen.
    %
    % NOTE: "clen" must be EVEN!
    %

    freqs = df * (0:clen/2);
end