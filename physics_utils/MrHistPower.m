%
% Name
%   MrHistPower
%
% Purpose
%   Histogram the power .
%
% Calling Sequence
%   HIST_PWR = MrHistPower(DATA, WINDOW, NOVERLAP, NFFT, FS)
%     Create a spectrogram of DATA. Break data into segments WINDOW number
%     of points long and apply a window to them. When shifting to the next
%     PSD, overlap by NOVERLAP points. Use NFFT points in each PSD, and
%     normalize the power by the correct sampling frequency FS. Then,
%     histogram the power in each frequency channel and return counts as a
%     function of power and frequency, HIST_PWR.
%
% Parameters
%   DATA             in, required, type = 1xN double
%   WINDOW           in, required, type = integer
%   NOVERLAP         in, required, type = integer
%   NFFT             in, required, type = integer
%   FS               in, required, type = double
%
% Returns
%   HIST_PWR         out, required, type=XxYxZ double
%   F                out, optional, type=1xN double
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-03-30      Written by Matthew Argall
%
function [hist_pwr, f] = MrHistPower(data, window, noverlap, nfft, fs)

	% Inputs
	root         = '/Users/argall/Documents/Work/Data/MMS/DFG/';
	fg_l1a_fname = fullfile(root, 'mms3_dfg_srvy_l1b_20150418_v0.0.1.cdf');
	fg_l1b_fname = fullfile(root, 'mms3_dfg_f128_l1a_20150418_v0.7.1.cdf');
	fg_l1a       = mms_fg_read_l1b(fg_l1a_fname);
	fg_l1b       = mms_fg_read_l1b(fg_l1b_fname);

keyboard;

	% Select range 2 data that is not burst mode.
	iGood   = find(range == 2 & tm == 22);
	B       = B(iGood, :);
	t_epoch = t_epoch(iGood);
	clear range tm
	
	% Convert epoch time to second since the first epoch
	t_ref = t_epoch(1,1);
	t_sse = MrCDF_epoch2sse(t_epoch, t_ref);
	
	% Compute the sample rate
	dt       = mode(diff(t_sse));
	fs       = 1.0 / dt;
	nfft     = fix(10 / dt);
	noverlap = fix(nfft / 2);
	window   = nfft;
	df       = 1.0 / (nfft * dt);
	
	% Compute the PSD
	[~, f, ~, Pxx] = spectrogram(double(B(:,1)), window, noverlap, nfft, fs);
	
	% Log-scale the power spectra
	Pxx = log10(Pxx);
	
	% Deterimine histogram bin sizes
	pmin     = min(Pxx(:));
	pmax     = max(Pxx(:));
	nbins    = 100;
	bin_size = (pmax - pmin) / (nbins - 1);
	edges    = pmin + (0:1:(nbins-1)) * bin_size;
	
	% Histogram
	hcount = zeros(nbins, length(f));
	for ii = 1 : length(f)
		hcount(:, ii) = histc(Pxx(ii, :), edges);
	end
	
	% Find the median power at each frequency
	theFloor = median(hcount, 1);

	% Overplot the median power over the histogrammed power
	hold on

	% Plot the distribution of powers at each frequency.
	surf(f, edges, hcount);
	title('Noise Floor');
	xlabel('Frequency (Hz)');
	xlim([min(f) max(f)]);
	ylabel({'Power' 'Log(nT^2 / Hz)'});
	ylim([min(edges) max(edges)]);
	
	% Change the view
	view([0, 90]);
	
	% Plot the median power (noise floor)
	plot(f, theFloor);
	
	% Create a colorbar
	cb = colorbar('eastoutside');
	set(get(cb, 'YLabel'), 'String', 'Counts');
end


