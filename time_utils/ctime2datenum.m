%
% Name:
%    ctime2datenum
%
% Purpose:
%    Convert Cluster time (seconds since 01 Jan 1970) to MatLab's
%    datenumber.
%
% Calling Sequence:
%    TOUT = ctime2datenum(CTIME)
%        Return MatLab date number converted from Cluster time.
%
% Parameters
%    CTIME:        in, required, type = double array
%
% Returns:
%    TOUT:         out, required, type = double array
%
% Releases:
%   7.14.0.739 (R2012a)
%
% Required Products:
%   None
%
% History:
%   2014-12-01      Written by Matthew Argall
%
function tout = ctime2datenum(cTime)
		tout = cTime / 86400.0 + datenum([1970 01 01]);
end