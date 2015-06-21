%
% Name
%   MrErrorLogger
%
% Purpose
%   Write text and error messages into a log file.
%
% Properties
%   FILENAME            Name of the log file.
%   FILEID              File identifier of the log file.
%   ALERT               Flag to alert user of errors.
%   IMMEDIATE           Flush the file buffer immediately after writing.
%   TRACEBACK           Include the stack traceback.
%   LASTMESSAGE         The last message written to the log file.
%   DELETE_ON_DESTROY   Delete the log file after object is destroyed.
%   STATUS              Status of the error logger.
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-20      Written by Matthew Argall
%
classdef MrErrorLogger < handle

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Object Properties \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	properties
		filename           % Name of the log file
		fileID             % File ID of the log file
		alert              % Flag to provide user alert messages
		immediate          % Flush the file buffer immediately
		traceback          % Flag to include traceback reports
		lastmessage        % Last error message
		delete_on_destroy  % Delete the log file when object is destroyed
		status             % Current status of the error logger
	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Static Methods \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	methods (Static)
		% EXTERNAL STATIC METHODS
	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Normal Methods \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	methods
		%
		% Purpose
		%   Instatiate a MrErrorLogger object.
		%
		% Calling Sequence
		%   OBJ = MrErrorLogger()
		%     Create an object handle OBJ to a MrErrorLogger object.
		%
		%   OBJ = MrErrorLogger(FILENAME)
		%     Messages will be written to a file with name FILENAME.
		%
		%   OBJ = MrErrorLogger(__, 'ParamName', ParamValue)
		%     Any of the parameter name-value pairs listed below.
		%
		% Parameters
		%   FILENAME:       in, optional, type=char, default='error_logger_yyyymmddHHMMSS_######.log'
		%   'Alert'         in, optional, type=boolean, default=false
		%                   Alert user by printing message to command window.
		%   'Delete'        in, optional, type=boolean, default=false
		%                   Delete the log file after the object is destroyed.
		%   'Status'        in, optional, type=integer, default=0
		%                   Status of the logger file.
		%   'Timestamp'     in, optional, type=boolean, default=false
		%                   Append a timestamp to the file name. If FILENAME is not
		%                     given, the default file will include a timestamp.
		%   'Traceback'     in, optional, type=boolean, default=true
		%                   Include the traceback report with each logged message.
		%
		% Returns
		%   OBJ             out, required, type=structure
		%
		function obj = MrErrorLogger(varargin)
			% Defaults
			alert             = false;
			delete_on_destroy = false;
			immediate         = true;
			status            = uint8(1);
			timestamp         = false;
			traceback         = true;
			
			% Default filename
			if mod(nargin, 2) == 0
				logFile  = fullfile( pwd(), ...
				                     [ 'error_logger_' ...
				                       datestr(now(), 'yyyymmddHHMMSS') '_' ...
				                       num2str( randi([1e5, 999999], 1, 'uint32') ) '.log' ] );
				timestamp = false;
			else
				logFile  = varargin{1};
				varargin = varargin{2:end};
			end
		
			% Number of optional arguments
			nOptArgs = length(varargin);
			for ii = 1 : 2 : nOptArgs
				switch varargin{ii}
					case 'Alert'
						alert = varargin{ii+1};
					case 'Delete'
						delete_on_destroy = varargin{ii+1};
					case 'Status'
						status = varargin{ii+1};
					case 'Timestamp'
						timestamp = varargin{ii+1};
					case 'Traceback'
						traceback = varargin{ii+1};
					otherwise
						error(['Unknown input parameter "' varargin{ii} '".']);
				end
			end
			
			% Relative name given? -- Make fully qualified.
			[pathstr, name, ext] = fileparts(logFile);
			if ~isempty(ext)
				name = [name '.' ext];
			end
			if strcmp(name, logFile)
				logFile = fullfile( pwd(), logFile );
			end
			
			% Add a timestamp to the file name?
			if timestamp
				% Separate file parts
				[pathstr, name, ext] = fileparts(logFile);
				
				% Create time stamp
				tstamp = [ datestr(date(), 'yyyymmddHHMMSS') '_' ...
				           num2str( randi([1e5, 999999], 1, 'uint32') ) ];
				
				% Append time stamp
				logFile = fullfile( pathstr, [name '_' tstamp] );
				if ~isempty(ext)
					logFile = [logFile '.' ext];
				end
			end
			
			% Set object properties
			obj.filename          = logFile;
			obj.alert             = alert;
			obj.traceback         = traceback;
			obj.delete_on_destroy = delete_on_destroy;
			obj.status            = status;
		end
		
		
		%
		% Class deconstructor.
		%
		% Calling Sequence
		%   obj.delete
		%     Cleanup after the MrErrorlogger object is deleted.
		%
		function [] = delete(obj)
			% Close the file
			obj.close();
			
			% Delete the log file
			if obj.delete_on_destroy && obj.status ~= 2
				if exist( obj.filename, 'file' ) == 2
					delete, obj.filename
				end
			end
		end
		
		
		%
		% Flust buffer to file
		%
		% Calling Sequence
		%   obj.flush
		%     Flush the file buffer.
		%
		function [] = flush(obj)
			%
			% Apparently, FPRINTF() and FWRITE() flush the buffer
			% immediately after each call. I leave this method
			% here in case I am wrong.
			%
		end
		
		
		%
		% Display the last message
		%
		% Calling Sequence
		%   obj.dispLastMessage
		%     Display the last error message.
		%
		function [] = dispLastMessage(obj)
			lastMessage = obj.lastMessage
			for ii = 1 : length(lastMessage)
				disp( lastMessage{ii} );
			end
		end
		
		
		%
		% Open the log file
		%
		% Calling Sequence
		%   open(OBJ, NEWLOGFILE) --- or --- obj.open(NEWLOGFILE)
		%     Open a new log file named NEWLOGFILE.
		%
		%   open(OBJ, NEWLOGFILE, DELETE_CURRENT)
		%     Indicate that the current log file should be deleted.
		%
		% Parameters
		%   NEWLOGFILE:     in, required, type=char
		%   DELETE_CURRENT: in, optional, type=boolean, default=false
		%
		function status = open(obj, newLogFile, delete_current)
			% Assume we are unsuccessful
			success = false;
			
			% Delete the current file
			if nargin < 3
				delete_current = false;
			end

			% Check if given directory exists
			[pathstr, name, ext] = fileparts(newLogFile);
			assert( exist(pathstr, 'dir') == 7, ...
			        ['Directory does not exist: "' pathstr '".'] );

			% Close the current file
			obj.close
			
			% Delete the current file, if it exists
			if delete_current && exist( obj.filename, 'file') == 2
				delete, obj.filename
			end
			
			% Open the new file for writing
			try
				fileID       = fopen( newLogFile, 'w' );
				obj.fileID   = fileID;
				obj.filename = newLogFile;
			catch ME
				if exist( newLogFile, 'file' ) == 7
					delete, newLogFile
				end
				rethrow(ME);
			end
			
			% Write header
			fprintf(obj.fileID, 'Error log file created %s', datestr( now(), 'yyyy-mm-dd HH:MM:SS\n\n' ));
			
			% Success opening file.
			status = true;
		end
		
		
		%
		% Close the log file
		%
		% Calling Sequence
		%   obj.close
		%     Close the log file.
		%
		function [] = close(obj)
			if ~isempty(obj.fileID)
				fclose(obj.fileID);
				obj.fileID = [];
			end
		end
		
		
		%
		% Clear the log file
		%
		% Calling Sequence
		%   obj.clear
		%     Clear the log file.
		%
		function [] = clear(obj)
			% Close the log file
			obj.close();
			
			% Delete the log file
			if exist(obj.filename, 'file') == 2
				delete, obj.filename
			end
			
			% Open a file with the same name
			obj.open( obj.filename );
			
			% Set status to waiting
			obj.status = 0;
		end
		
		
		%
		% Add text to the log file
		%
		% Calling Sequence
		%   obj.AddText(TEXT)
		%     Add text to the log file.
		%
		%   obj.AddText(TEXT, 'ParamName', ParamValue)
		%     Any parameter name-value pair given below.
		%
		% Parameters
		%   TEXT:           in, required, type=char/cell
		%   'Display':      in, optional, type=boolean, default=false
		%                   Display the text to the command window as well.
		%   'AddCaller':    in, optional, type=boolean, default=false
		%                   Add the calling program to the text.
		%
		function [] = AddText(obj, text, varargin)
			% Defaults
			display    = false;
			add_caller = false;
		
			% Check optional arguments
			nOptArgs = length(varargin);
			for ii = 1 : 2 : nOptArgs
				switch varargin{ii}
					case 'Display'
						display = varargin{ii+1};
					case 'AddCaller'
						add_caller = varargin{ii+1};
					otherwise
						error( ['Unknown parameter: "' varargin{ii} '".'] );
				end
			end
			
			% Ensure strings were given
			assert( ischar(text) || iscell(text), 'A string or cell array of strings must be given.' );
			if iscell(text)
				assert( max( cellfun(@ischar, text) ) == 1, 'Cell arrays must contain strings.');
			else
				text = { text };
			end
			
			% Add the calling function
			if add_caller
				% Get the callstack
				stk = dbstack();
				
				% Add the caller
				%   - The calling routine is one up from here
				caller = stk(2).name;
				text = [caller ': ' text];
			end
			
			% Open the log file, if necessary
			if isempty(obj.fileID)
				success = obj.open( obj.filename );
				assert( success, ['Cannot open log file: "' obj.filename '".'] );
			end
			
			% Write to file (and display).
			nLines = length(text);
			for ii = 1 : nLines
				fprintf( obj.fileID, [ text{ii} '\n' ] );
				if display
					disp( text );
				end
			end
			
			% Flush buffer to file
			if obj.immediate
				obj.flush();
			end
			
			% Set the status
			obj.status = 1;
			
			% Save the text
			obj.lastmessage = text;
		end
		
		
		%
		% Add error to the log file
		%
		% Calling Sequence
		%   obj.AddText(text)
		%     Add an error message to the log file.
		%
		% Parameters
		%   TEXT:           in, required, type=char/cell
		%
		function [] = AddError(obj, text)
			% Get the error message
			if nargin() < 2
				err  = lasterror();
				text = err.message;
				stk  = err.stack;
			else
				stk = dbstack();
			end
		
			% Add calling routine
			%   - The calling routine is one up from here
			caller = stk(2).name;
			text   = [caller ': ' text];
			
			% Write the error message
			obj.AddText(text);
			
			% Write the callstack
			stk = stk(2:end);
			if length(stk) > 0
				line_numbers = cellfun(@num2str, { stk.line }, 'UniformOutput', false );
				obj.AddText( strcat('    In', {' '}, { stk.name }, ' at (', line_numbers, ')' ) );
			end
		end
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Set Methods \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function obj = set.filename(obj, filename)
			obj.filename = filename;
		end
		function obj = set.alert(obj, alert)
			obj.alert = alert;
		end
		function obj = set.immediate(obj, immediate)
			obj.immediate = immediate;
		end
		function obj = set.traceback(obj, traceback)
			obj.traceback = traceback;
		end
		function obj = set.delete_on_destroy(obj, delete_on_destroy)
			obj.delete_on_destroy = delete_on_destroy;
		end
		function obj = set.status(obj, status)
			obj.status = status;
		end
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Get Methods \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function filename = get.filename(obj)
			filename = obj.filename;
		end
		function alert = get.alert(obj)
			alert = obj.alert;
		end
		function immediate = get.immediate(obj)
			immediate = obj.immediate;
		end
		function traceback = get.traceback(obj)
			traceback = obj.traceback;
		end
		function lastmessage = get.lastmessage(obj)
			lastmessage = obj.lastmessage;
		end
		function delete_on_destroy = get.delete_on_destroy(obj)
			delete_on_destroy = obj.delete_on_destroy;
		end
		function status = get.status(obj)
			status = obj.status;
		end
	end
end

