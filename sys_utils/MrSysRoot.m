%
% Name
%   MrSysRoot
%
% Purpose
%   Get the file system's root directory. For unix, this is "/". For
%     windows, matlabroot() is called and the root directory is taken to be
%     the first two characters (e.g. "C:").
%
% Calling Sequence
%   SYSROOT = MrSysRoot();
%     Return the file system's root directory.
%
% Returns
%   SYSROOT:        out, required, type=1xN char
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-01      Written by Matthew Argall
%
function sysroot = MrSysRoot()

	switch 1
		case ispc
			matroot = matlabroot();
			sysroot = matroot(1:2);
			
		case isunix
			sysroot = '/';
			
		otherwise
			error( 'Unknown file system. Cannot return system root directory.' )
	end
end