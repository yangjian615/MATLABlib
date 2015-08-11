%
% Name
%   mrstderr
%
% Purpose
%   Open or assign a file to stderr. To close the stderr file, do
%   one of the following:
%     >> mrstderr('');
%     >> mrstderr('stderr');
%     >> mrstderr(2);
%
% Calling Sequence
%   FILEID = mrstderr()
%     Return the file ID of the file assigned to stderr output.
%
%   mrstderr(FILENAME)
%     Assign standard error output to the file named FILENAME.
%     Additional options are::
%       ''       - MATLAB'S stderr (console)
%       'stderr' - MATLAB'S stderr (console)
%
%   mrstderr(FILEID)
%     Assign the file ID, FILEID, to stderr output. If FILEID = 2,
%     output will be directed to MATLAB's standard error output
%     (i.e. the console).
%
%   mrstderr(..., KEEP_OPEN)
%     Keep the old stdout file open. The default is to close the previous file.
%
%   FILEID = mrstderr(__)
%     Return the file ID of the file assigned to stderr output.
%
% Parameters
%   FILENAME     in, optional, type=char
%   FILEID       in, optional, type=integer, default=2
%
% Returns
%   FILEID       out, optional, type=integer
%
% Global Variables
%   STDERR       File ID of the stderr file.
%
% See Also:
%   mrfprintf, mrstdout, mrstdlog, MrErrorLogger
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-08-07      Written by Matthew Argall
%
function fileID = mrstderr( file, keep_open )

	% Establish global variables
	global stderr
	
	% Keep the old file open?
	if nargin < 2
		keep_open = false;
	end

	% Check if stderr exists and is valid
	%   - If stderr does not exist, GLOBAL will create it
	%     and set stderr = []
	tf_exist = ~isempty(stderr);

%------------------------------------%
% Get Current stderr File ID         %
%------------------------------------%
	if nargin == 0
		% Default stderr file ID.
		if ~tf_exist || isempty(stderr) || stderr < 0
			stderr = 2;
		end
		
		% Select the current stderr file.
		fileID = stderr;

%------------------------------------%
% Use a File Name                    %
%------------------------------------%
	elseif ischar( file )
		%
		% TODO:
		%   Determine if the file name is the one already in use.
		%     - Watch out for relative paths
		%     - fopen(stderr) will return the name current file.
		%
	
		% Close the previous file
		if ~keep_open && tf_exist && ~isempty(stderr) && stderr > 2
			% Indicate which file we are closing
			old_fname = fopen(stderr);
			fprintf( ['mrstderr: Closing stderr file "' old_fname '".\n'] );
			
			% Close the file
			fclose(stderr);
		end
	
		% Open the file
		if isempty(file) || strcmp(file, 'stderr')
			fileID = 2
		else
			fileID = fopen( file, 'w' );
		end
		
		% Make sure the file could be opened
		if fileID == -1
			error( ['Could not open file for writing: "' file '".'] );
		end

%------------------------------------%
% Use File ID                        %
%------------------------------------%
	else
		% Check if file ID is valid.
		assert( isnumeric(file), 'FILE must be a file ID returned by fopen.' );
		assert( file >= 2, 'FILE must be a file ID >= 2' );
		
		% Close the previous file
		if ~keep_open && tf_exist && ~isempty(stderr) && stderr ~= file && stderr > 2
			% Indicate which file we are closing
			old_fname = fopen(stderr);
			fprintf( ['mrstderr: Closing stderr file "' old_fname '".\n'] );
			
			% Close the file
			fclose(stderr);
		end

		% Assign the new 
		fileID = file;
	end
	
	% Set the standard error file ID.
	stderr = fileID;
end