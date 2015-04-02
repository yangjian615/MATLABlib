%--------------------------------------------------------------------------
% NAME
%   mrdeg2hms
%
% PURPOSE
%   Convert from degrees to arc-time (hour, minutes, seconds).
%
%   Calling Sequence:
%     [HR, MN, SEC] = deg2hms(DEGREES)
%     Convert degrees to hours, minutes, and seconds.
%
% Parameters
%   DEGREES         in, required, type=1xN double
%
% Returns
%   HR              out, required, type=1xN double
%   MN              out, optional, type=1xN double
%   SEC             out, optional, type=1xN double
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-03-22      Written by Matthew Argall
%--------------------------------------------------------------------------
function [hr, mn, sec] = mrdeg2hms(degrees)
	% Hours per degrees
	deg2hr  = 24.0 / 360.0;

	% Decimal hours, minutes, seconds
	hr  = degrees * deg2hr;
	mn  = mod(hr, 1) * 60.0;
	sec = mod(mn, 1) * 60.0;

	% Integer hours, minutes;
	hr = floor(hr);
	mn = floor(mn);
end