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
%   mrfprintf( fileID, formatSpec, A1, A2, ..., An )
%     Applies the formatSpec to all elements of arrays A1,...An in column order, and
%     writes the data to a text file. fprintf uses the encoding scheme specified in
%     the call to fopen. In place of a fileID returned by fopen, a character array
%     that names the standard output to which you want the text printed. Options are:
%       'stderr'  -- Adds error to standard error
%       'stdout'  -- Adds text to standard output
%       'logerr'  -- Adds error to standard log file.
%       'logtext' -- Adds text to standard log file.
%       'logwarn' -- Adds warning to standard log file.
%
%   mrfprintf( formatSpec, A1, A2, ..., An )
%     Formats data and displays the results on the screen.
%
%   mrfprintf( DATA )
%     Displays the contents of cell array DATA the screen, one element per line.
%     All elements must be character arrays.
%
%   mrfprintf( formatSpec, DATA )
%     Formats data in cell array DATA and displays the results on the screen.
%
%   mrfprintf( fileID, formatSpec, DATA )
%     Applies the formatSpec to all elements of cell array DATA in column order, and
%     writes the data to a text file. mrfprintf uses the encoding scheme specified in
%     the call to fopen.
%
% Parameters
%   FILEID       in, optional, type=char/integer
%   FORMATSPEC   in, optional, type=char
%   A1, ..., An  in, optional, type=any
%   DATA         in, optional, type=cell
%
% See Also:
%   mrstdout, mrstderr, mrstdlog, MrErrorLogger
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-08-09      Written by Matthew Argall
%   2016-04-01      Removed the "stdlog" and "logout" options. - MRA
%   2016-10-01      Cell arrays may be given. - MRA
%
function [] = mrfprintf( varargin )
	%
	% Will return message for
	%   - mrfprintf( DATA )
	%   - mrfprintf( formatSpec, DATA )
	%   - mrfprintf( fileID, formatSpec, DATA )
	%
	% Will return empty string for
	%   - mrfprintf( formatSpec, A1, A2, ..., An )
	%   - mrfprintf( fileID, formatSpec, A1, A2, ..., An )
	%
	msg = mrfprintf_get_msg();
	
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
		
			% Write to file
			if isempty( msg)
				fprintf(fileID, varargin{2:end});
			else
				fprintf(fileID, msg);
			end
	
	%------------------------------------%
	% STDOUT                             %
	%------------------------------------%
		elseif strcmp( varargin{1}, 'stdout' )
			% Get the file ID of stdout
			fileID = mrstdout();
		
			% Select stderr as the file id
			if isempty( msg )
				fprintf(fileID, varargin{2:end});
			else
				fprintf(fileID, msg);
			end
	
	%------------------------------------%
	% LOGTEXT                            %
	%------------------------------------%
		elseif strcmp( varargin{1}, 'logtext' )
			
			% Get the standard error logger object.
			logfile = mrstdlog();
			
			% Text must be formatted
			if isempty( msg )
				% Convert text to string
				text = sprintf( varargin{2:end} );
				logfile.AddText( text );
			
			% The log file can handle cell arrays, but only if
			% all elements are strings
			%   - mrprintf( fileID, DATA )
			elseif iscell( varargin{2} )
				logfile.AddText( varargin{2} );
			
			% Use the formatted string
			%   - mrprintf( fileID, formatSpec, DATA )
			else
				logfile.AddText( msg );
			end

	%------------------------------------%
	% LOGERR                             %
	%------------------------------------%
		elseif strcmp( varargin{1}, 'logerr' )
			% Get the error logger
			logfile = mrstdlog();
			
			% Error message structure
			if isobject(varargin{2})
				msg = varargin{2};
			end
			
			% Format inputs
			if isempty(msg)
				msg = sprintf( varargin{2:end} );
			end
				
			% Add the error
			logfile.AddError(msg);
		
	%------------------------------------%
	% LOGWARN                            %
	%------------------------------------%
		elseif strcmp( varargin{1}, 'logwarn' )
			% Get the log file
			logfile = mrstdlog();
			
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
				
				% Format the inputs
				if isempty( msg )
					msg = sprintf( varargin{2:end} );
				end
			end

			% Add the warning
			logfile.AddWarning(msgID, msg);
	
	%------------------------------------%
	% Regular fprinf                     %
	%------------------------------------%
		% Could be 
		%   - fprintf( formatSpec, DATA )
		%   - fprintf( formatSpec, A1, ..., An )
		else
			if isempty( msg )
				fprintf( varargin{:} );
			else
				fprintf( msg );
			end
		end

%------------------------------------%
% Regular fprinf                     %
%------------------------------------%
	% Could be 
	%   - fprintf( DATA )
	%   - fprintf( fileID, formatSpec, A1, ..., An)
	else
		if isempty( msg )
			fprintf( varargin{:} );
		else
			fprintf( msg );
		end
	end

% ----------------------------------------------------------------------------------------
% ****************************************************************************************
% ----------------------------------------------------------------------------------------
	%
	% Name
	%   mrfprintf_get_msg
	%
	% Purpose
	%   Extract text from the optional arguments given to mrfprinf. Allow the message
	%   to be given in the form of a cell array instead of multiple inputs.
	%
	% Calling Sequence
	%   msg = mrfprintf_get_msg()
	%     Create the message MSG from the optional arguments given to mrfprintf.
	%
	% MATLAB release(s): 9.0.0.341360 (R2016a)
	% Required Products: None
	%
	% History:
	%   2015-08-09      Written by Matthew Argall
	%
	function txt = mrfprintf_get_msg
		% Number of arguments given
		nArgs = length(varargin);
		
		% Determine if a format spec was given
		%   - Test on '%3$0-12.5bu'
		%   - Example from http://www.mathworks.com/help/matlab/ref/sprintf.html?searchHighlight=sprintf#inputarg_formatSpec
		fmt = '%([0-9]+$)?([ -+0#])?([0-9]+(.[0-9]+)?)?([])?[diouxXfeEgGcs]';
		
		% The last argument can be a cell array
		%   a) mrfprintf( cell )
		%   b) mrfprintf( formatSpec, cell )
		%   c) mrfprintf( fileID, formatSpec, cell )
		if iscell( varargin{end} )
			% Is the second to last argument a format spec?
			if nArgs > 2 && ischar( varargin{end-1} )
				tf_fmt = ~isempty( regexp( varargin{2}, fmt, 'once' ) );
			else
				tf_fmt = false;
			end
			
			% If it is a format spec
			if tf_fmt
				% Use sprintf to convert them to text.
				txt = sprintf( varargin{end-1}, varargin{end} );
			else
				% Must be strings. Each string on a new line.
				assert( all( cellfun(@ischar, varargin{end} ) ), 'Without formatSpec, cell contents must be strings.' );
				txt = sprintf( '%s\n', varargin{end}{:} );
			end
		else
			txt = '';
		end
	end
end

