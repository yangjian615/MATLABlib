%
% Name:
%   MrIntervalsX
%
% Purpose:
%   Find continuous data intervals within an evenly spaced, monotonic
%   vector of points.
%
% Calling Sequence:
%   IDATA = MrIntervalsX(X);
%     Find the indices that bracket continuous data intervals, IDATA,
%     within a monotic and evenly space array, X.
%
%   IDATA = MrIntervalsX(X, DELTA_X);
%     Provide the sampling interval DELTA_X -- the spacing between
%     points in X. If not given, the median difference between
%     adjacent points is used.
%
% Parameters:
%   X:            in, required, type = 1xN double
%   DELTA_X:      in, optional, type = double
%
% Returns:
%   IDATA:        out, required, type = 2xN integer array
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-03-26      Written by Matthew Argall
%   2015-04-14      Renamed from fsm_intervals_find to MrIntervalsX.m - MRA
%
function idata = MrIntervalsX(X, delta_x)

%------------------------------------%
% Time and Sampling Intervals        %
%------------------------------------%

	% Take the difference between adjacent points
	dx = diff(X);

	% Must know the sampling interval
	if nargin < 2
		delta_x = median(dx);
	end

%------------------------------------%
% FGM Data Intervals                 %
%------------------------------------%

	% Number of sampling intervals between data points.
	%   - Round to remove the effect of small systematic noise.
	ndt = round(dx / delta_x);

	% Locations of the data gaps
	igaps = find(ndt > 1.0);

	% Number of data intervals
	%   - One more than the number of data gaps.
	n_intervals = length(igaps) + 1;
	
	% Allocate memory
	%   - First column holds the beginning of an interval
	%   - Second column holds the end of a data interval.
	idata      = zeros(2, n_intervals);
	idata(1,:) = 1.0;
	
	% The first data interval begins at 1, the last ends at index "end"
	idata(1,1)   = 1;
	idata(2,end) = length(X);

	% Other data intervals begin one point after.
	%   - The first point just prior to a data gap.
	%   - The first point just after a data gap.
	idata(1, 2:n_intervals) = igaps+1;
	idata(2, 1:end-1)       = igaps;
end
