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
%   IDATA = MrIntervalsX(__, TOL);
%     Provide the tolerance in gap size determination. Normally, the
%     mean spacing between points DELTA_X is compared to the actual
%     spacing between points DX. DX/DELTA_X is expected to round to
%     a value of 1.0. Set the tolerance TOL to an integer value
%     greater than 0 to relax this condition.
%
% Parameters:
%   X:            in, required, type = 1xN double
%   DELTA_X:      in, optional, type = double
%   TOL:          in, optional, type = double
%
% Returns:
%   IDATA:        out, required, type = 2xN integer array
%   NINTERVALS:   out, optional, type = integer
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-03-26      Written by Matthew Argall
%   2015-04-14      Renamed from fsm_intervals_find to MrIntervalsX.m - MRA
%   2015-12-07      Added the TOL parameter. - MRA
%
function [idata, nIntervals] = MrIntervalsX(x, delta_x, tol)

%------------------------------------%
% Time and Sampling Intervals        %
%------------------------------------%

	% Take the difference between adjacent points
	dx = diff(x);

	% Must know the sampling interval
	if nargin < 2 || isempty(delta_x)
		delta_x = median(dx);
	end
	if nargin < 3
		tol = 1;
	end

%------------------------------------%
% Data Intervals                     %
%------------------------------------%

	% Number of sampling intervals between data points.
	%   - Round to remove the effect of small systematic noise.
	ndt = round(dx / delta_x);

	% Locations of the data gaps
	igaps = find(ndt > tol);

	% Number of data intervals
	%   - One more than the number of data gaps.
	nIntervals = length(igaps) + 1;
	
	% Allocate memory
	%   - First column holds the beginning of an interval
	%   - Second column holds the end of a data interval.
	idata      = zeros(2, nIntervals);
	idata(1,:) = 1.0;
	
	% The first data interval begins at 1, the last ends at index "end"
	idata(1,1)   = 1;
	idata(2,end) = length(x);

	% Other data intervals begin one point after.
	%   - The first point just prior to a data gap.
	%   - The first point just after a data gap.
	idata(1, 2:nIntervals) = igaps+1;
	idata(2, 1:end-1)      = igaps;
end
