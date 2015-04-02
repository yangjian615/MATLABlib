%
% Name:
%    datenum2ctime
%
% Purpose:
%    Convert MatLab's datenumber to Cluster time (seconds since
%    01 Jan 1970).
%
% Calling Sequence:
%    CTIME = ctime2datenum(DATENUM)
%        Return Cluster time converted to MatLab's date number.
%
% Parameters
%    DATENUM:      in, required, type = double array
%
% Returns:
%    CTIME:        out, required, type = double array
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
function cTime = datenum2ctime(dateNum)
		cTime = ( dateNum - datenum([1970 01 01]) ) * 86400.0;
end