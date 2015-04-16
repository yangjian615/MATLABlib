%
% Name:
%   MrGapsX
%
% Purpose:
%   Find data gaps within an evenly spaced, monotonic vector of
%   points.
%
% Calling Sequence:
%   IGAPS = MrGapsX(X);
%     Find the elements in X just before and just after a data gap.
%
%   IGAPS = MrIntervalsX(X, DELTA_X);
%     Provide the sampling interval DELTA_X -- the spacing between
%     points in X. If not given, the median difference between
%     adjacent points is used.
%
%   [__, GAPSIZE] = MrIntervalsX(__);
%     Also return the number of missing points in each gap.
%
% Parameters:
%   X:            in, required, type = 1xN double
%   DELTA_X:      in, optional, type = double
%
% Returns:
%   IGAPS:        out, required, type = 2xN integer array
%   GAPSIZE:      out, optional, type = 1xN integer array
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-14      Written by Matthew Argall
%
function [iGaps, gapSize] = MrGapsX(X, delta_x)

%------------------------------------%
% Sampling Intervals                 %
%------------------------------------%

	% Take the difference between adjacent points
	dx = diff(X);

	% Must know the sampling interval
	if nargin < 2
		delta_x = median(dx);
	end

%------------------------------------%
% Data Gaps                          %
%------------------------------------%

	% Number of sampling intervals between data points.
	%   - Round to remove the effect of small systematic noise.
	ndt = round(dx / delta_x);

	% Locations of the data gaps
	%   - First column holds the point just prior to a gap.
	%   - Second column holds the point just after a gap.
	igaps = find(ndt > 1.0);
	igaps = [igaps; igaps + 1];
	
	% Estimate the gap size
	if nargout > 1
		gapSize = round( ( X(iGaps(2,:)) - X(iGaps(1,:)) ) / delta_x ) - 1;
	end
end
