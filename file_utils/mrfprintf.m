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
%       'stdout'  -- Adds text  to standard output
%       'stderr'  -- Adds error to standard error
%       'stdlog'  -- Adds error to standard log file.
%       'logerr'  -- Adds error to standard log file.
%       'logout'  -- Adds text  to standard output, routed through log object.
%       'logtext' -- Adds text  to standard log file.
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
%   2015-08-09      Written by Matthew Argall
%
function [] = mrfprintf( varargin )

%------------------------------------%
% STDOUT, STDERR, STDLOG, etc.       %
%------------------------------------%
	if ischar(varargin{1})
	%------------------------------------%
	% STDERR                             %
	%------------------------------------%
		if strcmp( varargin{1}, 'stderr' )
			% Get the file ID of stderr
			fileID = mrstderr();
		
			% Select stderr as the file id
			fprintf(fileID, varargin{2:end});
	
	%------------------------------------%
	% STDOUT                             %
	%------------------------------------%
		elseif strcmp( varargin{1}, 'stdout' )
			% Get the file ID of stdout
			fileID = mrstdout();
		
			% Select stderr as the file id
			fprintf(fileID, varargin{2:end});
	
	%------------------------------------%
	% LOGFILE                            %
	%------------------------------------%
		%
		% TODO:
		%   If 'logout' outputs to standard output, routed through
		%   the log object, should 'logerr' not output to standard
		%   error, routed through the log object?
		%
		%   Or perhaps 'log*' should all go into the log file. But
		%   then, how to direct to stdout and stderr via the log
		%   file with the stdout and stderr methods?
		%
	
		elseif ~isempty( regexp( varargin{1}, '^(stdlog|logout|logtext)$', 'once' ) )
			% Convert text to string
			text = sprintf( varargin{2:end} );
			
			% Get the standard error logger object.
			logfile = mrstdlog();

			% Add the error, warning, or message
			switch varargin{1}
				case 'stdlog'
					logfile.AddError( text );
				case 'logout'
					logfile.stdout( text );
				case 'logtext'
					logfile.AddText( text );
				otherwise
					% Not possible
			end
		
	%------------------------------------%
	% LOGERR                             %
	%------------------------------------%
		elseif strcmp( varargin{1}, 'logerr' )
			% Error message structure
			if isobject(varargin{2})
				msg = varargin{2};
			else
				msg = sprintf( varargin{2:end} );
			end
			
			% Get the error logger
			logfile = mrstdlog();
			
			% Add the error
			logfile.AddError(msg);
		
	%------------------------------------%
	% LOGWARN                            %
	%------------------------------------%
		elseif strcmp( varargin{1}, 'logwarn' )
			% Was a message identifier given?
			%   - component:mneumonic
			%   - Must begin with a letter
			%   - Followed by any alphanumeric or underscore
			%   - can be component:mneumonic:mneumonic:...
			if ~isempty( regexp( varargin{2}, '^[A-Za-z][A-Za-z0-9_]*(:[A-Za-z][A-Za-z0-9_]*)+$', 'once') )
				msgID = varargin{2};
				msg   = sprintf( varargin{3:end} );
			else
				msgID = '';
				msg   = sprintf( varargin{2:end} );
			end
			
			% Get the log file
			logfile = mrstdlog();

			% Add the warning
			logfile.AddWarning(msgID, msg);
	
	%------------------------------------%
	% Regular fprinf                     %
	%------------------------------------%
		else
			fprintf( varargin{:} );
		end

%------------------------------------%
% Regular fprinf                     %
%------------------------------------%
	else
		fprintf( varargin{:} );
	end
end

