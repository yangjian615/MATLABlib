%
% Name
%   MrFile_VersionCompare
%
% Purpose
%   Compare the versions of two files.
%
% Calling Sequence
%   RESULT = MrFile_VersionCompare(FILE1, FILE2)
%     Compares the version of FILE1 to that of FILE2. The RESULT is -1 if
%     FILE1 is older, 0 if FILE1 is the same version, and 1 if FILE1 is
%     newer.
%
%   RESULT = MrFile_VersionCompare(__, REGEX)
%     Specify the regular expression REGEX used to extract version
%     numbers. Used with the 'tokens' flag set in regexp(), i.e. each
%     numeric component of the version number should be enclosed in 
%     parentheses so that they can be extracted. For a version number of
%     v0.3.2, a regex of 'v(0)\.(3)\.(2)' will match 'v0.3.2' and extract
%     '0', '3', '2'.
%
% Parameters
%   FILE1           in, required, type = char
%   FILE2           in, required, type = char
%   REGEX           in, optional, type = char, default = '([0-9]+)\.([0-9]+)\.([0-9]+)'
%
% Returns:
%   RESULT          out, required, type = integer
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-08      Written by Matthew Argall
%
function result = MrFile_VersionCompare(file1, file2, regex)

	% FILE1 and FILE2 must be scalar strings
	assert(ischar(file1) && isrow(file1), 'FILE1 must be a single file name.')
	assert(ischar(file2) && isrow(file2), 'FILE2 must be a single file name.')

	% String for extracting version elements
	if nargin < 3
		regex = '([0-9]+)\.([0-9]+)\.([0-9]+)';
	end
	
	% Extract the version from each file
	vfile1 = regexp(file1, regex, 'tokens');
	vfile2 = regexp(file2, regex, 'tokens');
	
	% Get rid of the nested cells
	vfile1 = vfile1{1};
	vfile2 = vfile2{1};
	
	% Compare	
	ii     = 1;
	result = 0;
	while result == 0 && ii <= length(vfile1)
		
		% Newer version
		if vfile1{ii} > vfile2{ii}
			result = 1;
			
		% Older version
		elseif vfile1{ii} < vfile2{ii}
			result = -1;
		end
		
		% Move to the next part
		ii = ii + 1;
	end
end