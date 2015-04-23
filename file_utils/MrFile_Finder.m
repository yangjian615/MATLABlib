%
% Name
%   MrFile_Search
%
% Purpose
%   Find files in the file system. File and directory names can include any
%   tokens recognized by MrTokens.
%
% Calling Sequence
%   FILENAMES = MrFile_Search(FILEPATH)
%     Find all file names that match the filepath FILEPATH.
%
% Parameters
%   PATTERN:        in, optional, type=char
%
% Returns
%   NAMES:          out, optional, type=1XN cell
%   COUNT:          out, optional, type=integer
%
% Examples
%   Find files in a "spacecraft/Year/Month/" directory structure with a 
%   'YearMonthDay' filename pattern.
%     1. Example file name:
%       >> example = '/Users/argall/Documents/Work/Data/RBSP/Ephemeris/A/2013/11/rbspa_def_MagEphem_TS04D_20131101_v1.0.0.h5';
%
%     2. File path pattern. %Y, %M, and %d represent year, month, and day, respectively.
%        "%(" and "%)" will protect the regex patterns "(a|b)" and "(A|B)" that find
%        spacecraft A or B so that they are not interpreted as part of the file path:
%       >> directory = '/Users/argall/Documents/Work/Data/RBSP/Ephemeris/%((A|B)%)/%Y/%M/';
%       >> filename  = 'rbsp%((a|b)%)_def_MagEphem_TS04D_%Y%M%d_v*.h5';
%       >> filepath  = fullfile(directory, filename);
%
%    3. Find the files
%       >> results = MrFile_Finder(filepath);
%       >> length(results)
%             = 122
%       >> vertcat(results{:})           % An exerpt
%           /Users/argall/Documents/Work/Data/RBSP/Ephemeris/A/2013/11/rbspa_def_MagEphem_TS04D_20131101_v1.0.0.h5
%           /Users/argall/Documents/Work/Data/RBSP/Ephemeris/A/2013/11/rbspa_def_MagEphem_TS04D_20131102_v1.0.0.h5
%           /Users/argall/Documents/Work/Data/RBSP/Ephemeris/A/2013/11/rbspa_def_MagEphem_TS04D_20131103_v1.0.0.h5
%           /Users/argall/Documents/Work/Data/RBSP/Ephemeris/A/2013/12/rbspa_def_MagEphem_TS04D_20131201_v1.0.0.h5
%           /Users/argall/Documents/Work/Data/RBSP/Ephemeris/A/2013/12/rbspa_def_MagEphem_TS04D_20131202_v1.0.0.h5
%           /Users/argall/Documents/Work/Data/RBSP/Ephemeris/A/2013/12/rbspa_def_MagEphem_TS04D_20131203_v1.0.0.h5
%           /Users/argall/Documents/Work/Data/RBSP/Ephemeris/B/2013/11/rbspb_def_MagEphem_TS04D_20131101_v1.0.0.h5
%           /Users/argall/Documents/Work/Data/RBSP/Ephemeris/B/2013/11/rbspb_def_MagEphem_TS04D_20131102_v1.0.0.h5
%           /Users/argall/Documents/Work/Data/RBSP/Ephemeris/B/2013/11/rbspb_def_MagEphem_TS04D_20131103_v1.0.0.h5
%           /Users/argall/Documents/Work/Data/RBSP/Ephemeris/B/2013/12/rbspb_def_MagEphem_TS04D_20131201_v1.0.0.h5
%           /Users/argall/Documents/Work/Data/RBSP/Ephemeris/B/2013/12/rbspb_def_MagEphem_TS04D_20131202_v1.0.0.h5
%           /Users/argall/Documents/Work/Data/RBSP/Ephemeris/B/2013/12/rbspb_def_MagEphem_TS04D_20131203_v1.0.0.h5
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-01      Written by Matthew Argall
%   2015-04-23      Renamed PATTERN to FILEPATH as input parameter. Be smarter
%                     about determining the system root on Windows machines. - MRA
%
function [tree, count] = MrFile_Finder(filepath)

	% Current path
	path    = pwd();
	sep     = filesep();
%	sysroot = MrSysRoot();
	
	% Look for the system root specifier.
	if ispc
		% See if the 
		if strmatch(filepath, '[A-Za-z]:')
			sysroot = filepath(1:2);
		else
			sysroot = path(1:2);
		end
	elseif ismac
		sysroot = '/';
	else
		error('Unexpected file system.');
	end

%------------------------------------%
% First Token                        %
%------------------------------------%
	% Break the FILEPATH into parts
	parts  = regexp(filepath, sep, 'split');
	nParts = length(parts);
	
	% Find the directory elements with a token identifier
	%   - Create inputs to the regular expression
	%   - CellFun requires cell arrays
	allTokens     = MrTokens();
	token_cell    = cell(1, nParts);
	once_cell     = cell(1, nParts);
	token_cell(:) = { [ '(?<!\\)%[' allTokens ']' ] };
	once_cell(:)  = { 'once' };
	tf_token      = cellfun(@regexp, parts, token_cell, once_cell, 'UniformOutput', false);
	tf_token      = ~cellfun(@isempty, tf_token);
	
	% Where do the tokens occur?
	iTokens = find(tf_token);
	nTokens = length(iTokens);
	
	% Parse the FILEPATH into a part without tokens and a part with tokens
	if isempty(iTokens)
		[root, subpattern, ext] = fileparts(filepath);
		subpattern = [subpattern ext];
		
	% Token is in the first directory part
	elseif iTokens(1) == 1
		root       = sysroot;
		subpattern = parts(1);
	
	% Token is in the middle
	else
		root       = fullfile(sysroot, parts{1:iTokens(1)-1});
		subpattern = parts{ iTokens(1) };
		subpattern = MrTokens_ToRegex( subpattern );
	end

%------------------------------------%
% Parse the Current Piece            %
%------------------------------------%

	% Change to the directory
	cd(root);
	
	% Get the directory contents
	[pathOut, count] = MrLS('Regex', subpattern);
	
	% No matches
	if count == 0
		cd(path);
		tree = {};
		return
	end
	
	% What part of the input path remains to us?
	%   - Nothing
	if (nTokens == 0) || (iTokens(1) == nParts)
		remainder = '';

	% All path parts beyond the part with the first token.
	%   - Lead with the file separator.
	else
		remainder = fullfile( sep, parts{ iTokens(1)+1:nParts } );
	end

%------------------------------------%
% Parse the Next Piece               %
%------------------------------------%

	% More things to find
	if ~isempty(remainder)
		% The directory trees that match our results
		tree = {};
		
		% Step through each directory found with MrLS
		for ii = 1 : count
			% Create the file path
			%   - root / pathOut(ii) / remainder
			next = fullfile(sysroot, root, pathOut{ii}, remainder);
			
			% Recursively search for the next part of the path
			tempTree = MrFile_Finder(next);
			
			% Keep the results
			if isempty(tree)
				tree = tempTree;
			else
				tree = [ tree tempTree ];
			end
		end

%------------------------------------%
% Parse Last Piece                   %
%------------------------------------%
	else
		% Form the complete file path.
		%   - Apply FullFile() as a cell function.
	  %   - Must create cell arrays out of inputs.
		count           = length(pathOut);
		sysroot_cell    = cell(1, count);
		root_cell       = cell(1, count);
		sysroot_cell(:) = { sysroot };
		root_cell(:)    = { root };
		tree            = cellfun(@fullfile, sysroot_cell, root_cell, pathOut, 'UniformOutput', false);
	end
	
	% Switch back to the original directory
	cd(path);
	
	% Count the results
	count = length(tree);
end