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
function [tree, count] = MrFile_Search(pattern)

	% Current path
	path    = pwd();
	sep     = filesep();
	sysroot = MrSysRoot();

%------------------------------------%
% First Token                        %
%------------------------------------%
	% Break the pattern into parts
	parts  = regexp(pattern, sep, 'split');
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
	
	% Parse the pattern into a part without tokens and a part with tokens
	if isempty(iTokens)
		[root, subpattern, ext] = fileparts(pattern);
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
			tempTree = MrFile_Search(next);
			
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