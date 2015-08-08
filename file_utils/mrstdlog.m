%
% Name
%   mrstdlog
%
% Purpose
%   Create or retrieve a standard error logging object.
%
%   To close the stdlog file, set FILENAME = ''.
%
% Calling Sequence
%   FILEID = mrstdlog()
%     Return the MrErrorLogger object assigned to stdlog output.
%
%   mrstdlog(FILENAME)
%     Open file named FILENAME and assign its file ID to 
%     stdout output.
%
%   mrstdlog(..., [MrErrorLogger PARAMS])
%     Include any additional parameter accepted by MrErrorLogger.
%
%   LOGFILE = mrstdlog(__)
%     Return the logger file object assigned to stdlog output.
%
% Parameters
%   FILENAME     in, optional, type=char
%
% Returns
%   LOGFILE      out, optional, type=object
%
% Global Variables
%   STDLOG       Error logging object assigned to stdlog.
%
% See Also:
%   mrfprintf, mrstdout, mrstderr, MrErrorLogger
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-08-07      Written by Matthew Argall
%
function logfile = mrstdlog( filename, varargin )

	% Establish global variables
	global stdlog
	
	% Check if stderr exists and is valid
	tf_exist = exist('stdlog', 'var') == 1;
	
	% Return the current logfile object
	if nargin == 0
		% Create a default logger object
		if ~tf_exist
			stdlog = MrErrorLogger('Timestamp', true, 'Delete', true);
			if nargout < 1
				disp(['Log file created: "' stdlog.filename '".']);
			end
		end
	
		logfile = stdlog;
		
	% Open a file
	elseif ischar( filename )
		% Destroy the old logger object
		if tf_exist && ~isempty(stdlog)
			% Indicate which file we are closing.
			fprintf( ['Closing log file "' stdlog.filename '".\n'] );
		
			% Close the file and delete the object.
			stdlog.delete;
		end

		% Create a new error logger object
		if nargin > 1
			logfile = MrErrorLogger( filename, varargin{:} );
		else
			if isempty(filename)
				logfile = [];
			else
				logfile = MrErrorLogger( filename );
			end
		end
	
	% Use the given file ID
	else
		error( 'FILENAME must be a character array.' );
	end
	
	% Set the standard error file ID.
	stdlog = logfile;
end