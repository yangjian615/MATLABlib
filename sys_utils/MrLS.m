%
% Name
%   MrLS
%
% Purpose
%   Get the current directory listing.
%
% Calling Sequence
%   MrLS
%     Print the contents of the current directory to the command window.
%
%   MrLS('ParamName', ParamValue);
%     Filter the contents of the directory with any param-value pair listed
%     below, then print to command window.
%
%   NAMES = MrLS(__);
%     Instead of printing to the display, return directory listing as a
%     cell array of strings.
%
%   [NAMES, COUNT] = MrLS(__);
%     Also return the number of items found.
%
% Parameters
%   'Directories':      in, optional, type=boolean
%                       If true, only directories will be returned. Files
%                         are excluded from results.
%   'Files':            in, optional, type=boolean
%                       If true, only files will be returned. Directories
%                         are excluded from results.
%   'MarkDirectories':  in, optional, type=boolean
%                       If set, directories will be marked with a trailing
%                         file separator.
%   'MatchString':      in, optional, type=1xN char
%                       A string used with the strmatch() function to
%                         filter results.
%   'Regex':            in, optional, type=1xN char
%                       A string used with the regexp() function to filter
%                         results.
%
% Returns
%   NAMES:          out, optional, type=1XN cell
%   COUNT:          out, optional, type=integer
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-01      Written by Matthew Argall
%
function [names, count] = MrLS(varargin)

	% Defaults
	directories      = false;
	files            = false;
	regex            = '';
	mark_directories = false;
	matchstr         = '';

	% Optional arguments
	nOptArgs = length(varargin);
	for ii = 1 : 2 : nOptArgs
		switch varargin{ii}
			case 'Regex'
				regex = varargin{ii+1};
			case 'Directories'
				directories = varargin{ii+1};
			case 'Files'
				files = varargin{ii+1};
			case 'MarkDirectories'
				mark_directories = varargin{ii+1};
			case 'MatchString'
				matchstr = varargin{ii+1};
			otherwise
				error( ['Parameter not recognized "' varargin{ii} '".'] );
		end
	end
	
	% We have to return something.
	assert( ~(files && directories), 'Files and Directories cannot both be true.' )
	assert( isempty(matchstr) || isempty(regex), 'MatchString and Regex cannot be used together.')

%------------------------------------%
% Directory Listing                  %
%------------------------------------%
	% Get the contents of the current folder
	dirStruct = dir();
	count     = length(dirStruct);
	
	% Keep files only
	if files
		dirStruct = dirStruct(  ~vertcat( dirStruct(:).isdir )' );
		count     = length(dirStruct);
	end
	
	% Keep directories only
	if directories
		dirStruct = dirStruct( [ dirStruct(:).isdir ] );
		count     = length(dirStruct);
	end
	
	% Extract the names
	names    = cell(1, count);
	names(:) = { dirStruct(:).name };

%------------------------------------%
% Mark Directories                   %
%------------------------------------%
	% Mark directories with the path separator
	%   - Directories remain ony if FILES = false.
	if mark_directories && ~files
		% Extract the directories
		dirs   = names( [ dirStruct(:).isdir ] );
		nDirs  = length(dirs);
		
		% Use sprintf append the file separator to the directory name.
		if nDirs > 0
			fmt    = cell(1, nDirs);
			sep    = cell(1, nDirs);
			fmt(:) = { '%s%s' };
			sep(:) = { filesep };
			dirs   = cellfun(@sprintf, fmt, dirs, sep, 'UniformOutput', false);

			% Put the directory names back into the structure
			names( [ dirStruct(:).isdir ] ) = dirs(:);
		end
	end
	
%------------------------------------%
% Apply Regex                        %
%------------------------------------%
	% Apply the regular expression
	if ~isempty(regex)
		regex_once    = cell(1, count);
		regex_cell    = cell(1, count);
		regex_once(:) = {'once'};
		regex_cell(:) = {regex};
		tf_pass       = cellfun(@regexp, names, regex_cell, regex_once, 'UniformOutput', false);
		tf_pass       = ~cellfun(@isempty, tf_pass);
		names         = names(tf_pass);
		count         = length(names);
	end
	
%------------------------------------%
% Apply StrMatch                     %
%------------------------------------%
	% Apply the regular expression
	if ~isempty(matchstr)
		% We need a cell array the same size as NAMES for CellFun to work.
		match_cell    = cell(1, count);
		match_cell(:) = { matchstr };
		
		% Find names that pass the strmatch test.
		tf_pass = cellfun(@strmatch, match_cell, names, 'UniformOutput', false);
		tf_pass = ~cellfun(@isempty, tf_pass);
		names   = names(tf_pass);
		count   = length(names);
	end

%------------------------------------%
% Display List                       %
%------------------------------------%
	% Display the names
	if nargout == 0
		fprintf('%s\n', names{:});
		clear names
	end
end