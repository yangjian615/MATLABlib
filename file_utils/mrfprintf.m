%
% Name
%   mrfprintf
%
% Purpose
%   Wrapper for MATLAB's fprintf() function. Enhancements include:
%     - fileID can be 'stdout', 'stderr', or 'stdlog'. This redirects
%       output to standard output, standard error, or standard
%       error logger files.
%
% Calling Sequence
%   mrfprintf( [fprintf Parameters] )
%     Write text exactly the same as fprintf would. Use any parameters
%     accepted by the fprintf function.
%
%   mrstderr( STDSTR, __ )
%     Instead of supplying a fileID, you can specify STDSTR, a character
%     array that names the standard output to which you want the text
%     printed. Options are
%       'stdout'  -- Standard output
%       'stderr'  -- Standard error
%       'stdlog'  -- Adds error to standard log file.
%       'logerr'  -- Standard error via log file (more verbose).
%       'logout'  -- Standard output via log file (more verbose).
%       'logtext' -- Adds text to standard log file.
%       'logwarn' -- Adds warning to standard log file.
%
% Parameters
%   STDSTR       in, optional, type=char
%   KEEP_OPEN    in, optional, type=boolean, default=false
%
% See Also:
%   mrstdout, mrstderr, mrstdlog, MrErrorLogger
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-20      Written by Matthew Argall
%
function [] = mrfprintf( varargin )

	% Output to stderr, stdout, or log file
	if ischar(varargin{1})
		% Output to stderr
		if strcmp( varargin{1}, 'stderr' )
			% Get the file ID of stderr
			fileID = mrstderr();
		
			% Select stderr as the file id
			fprintf(fileID, varargin{2:end});
	
		% Output to stdout
		elseif strcmp( varargin{1}, 'stdout' )
			% Get the file ID of stdout
			fileID = mrstdout();
		
			% Select stderr as the file id
			fprintf(fileID, varargin{2:end});
	
		% Output to logfile
		elseif ~isempty( regexp( varargin{1}, '^(stdlog|logerr|logout|logtext|logwarn)$', 'once' ) )
			% Get the standard error logger object.
			logfile = mrstdlog();
			
			% Convert text to string
			text = sprintf( varargin{2:end} );

			% Add the error, warning, or message
			switch varargin{1}
				case 'stdlog'
					logfile.AddError( text );
				case 'logerr'
					logfile.stderr( text );
				case 'logout'
					logfile.stdout( text );
				case 'logtext'
					logfile.AddText( text );
				case 'logwarn'
					logfile.AddWarning( text );
				otherwise
					% Not possible
			end
	
		% Regular fprintf command
		else
			fprintf( varargin{:} );
		end
		
	% Normal fprintf command.
	else
		fprintf( varargin{:} );
	end
end

