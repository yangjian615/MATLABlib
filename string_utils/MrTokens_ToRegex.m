%
% Name
%   MrTokens_ToRegex
%
% Purpose
%   Convert a string containing MrToken tokens to a regular expression.
%
% Calling Sequence
%   [TOKEN_MAP] = MrTokens_ToRegex()
%     Return a container_map object whos keys are tokens and whose values
%     are the associated regular expressions.
%
%   [REGEX] = MrTokens_ToRegex(PATTERN)
%     Convert a pattern of tokens, PATTERN, to a regular expression, REGEX.
%     PATTERN can contain any token recognized by MrTokens.m
%
% Parameters
%   PATTERN:        in, optional, type=1xN char
%
% Returns
%   TOKEN_MAP:      out, optional, type=container map
%   REGEX:          out, optional, type=1xN char
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-03-31      Written by Matthew Argall
%
function [regex] = MrTokens_ToRegex(pattern)

%------------------------------------%
% Tokens & Regular Expressions       %
%------------------------------------%
	% Create a table of tokens and regular expressions
	token_map      = containers.Map('KeyType', 'char', 'ValueType', 'char');
	token_map('Y') = '([0-9]{4})';
	token_map('y') = '([0-9]{2})';
	token_map('M') = '(0[0-9]|1[0-2])';
	token_map('C') = ['(January|February|March|April|May|June|' ...
                    'July|August|September|October|November|December)'];
	token_map('c') = '(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)';
	token_map('d') = '([0-2][0-9]|3[0-1])';
	token_map('D') = '([0-2][0-9]{2}|3[0-5][0-9]|36[0-6])';
	token_map('W') = '(Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday)';
	token_map('w') = '(Sun|Mon|Tue|Wed|Thu|Fri|Sat)';
	token_map('H') = '([0-1][0-9]|2[0-4])';
	token_map('h') = '(0[0-9]|1[0-2])';
	token_map('m') = '([0-5][0-9])';
	token_map('S') = '([0-5][0-9]|60)';
	token_map('f') = '\.([0-9]+)';
	token_map('1') = '([0-9][0-9]?[0-9]?)';
	token_map('2') = '([0-9][0-9]?[0-9]?)';
	token_map('3') = '([0-9][0-9]?[0-9]?)';
	token_map('4') = '([0-9][0-9]?[0-9]?)';
	token_map('A') = '(AM|PM)';
	token_map('z') = '(Z|AT|BT|NT|UT|[A-Z]{2}[0-9]|[A-Z]{3}|[A-Z]{4})';
	token_map('o') = '([+-]?[0-9]{2}:?[0-9]?[0-9]?)';
	token_map('?') = '?';
	
	% Return the token map?
	if nargin == 0
		regex = token_map;
		return
	end

	%
	% Make sure a single string was given.
	%   - MrTokens_Extract does not handle cell arrays of strings.
	%
	% TODO: Implement cell arrays of strings.
	%
	assert( ischar(pattern) && isrow(pattern), 'PATTERN must be a 1xN character array.' )

%------------------------------------%
% Prep PATTERN                       %
%------------------------------------%
	% Process input string
	%   - Replace "." with "\."
	%   - Replace "*" with ".*"
	pattern = regexprep(pattern, '\.', '\\.');
	pattern = regexprep(pattern, '\*', '.*');
	
	% Extract tokens
	[tokens, istart, iend] = MrTokens_Extract(pattern);
	nTokens                = length(tokens);
	
	% Parts of the pattern before and after the first token
	pre  = pattern(1:istart(1)-1);
	post = pattern(istart:end);

%------------------------------------%
% Step Through Each Token            %
%------------------------------------%
	% Start replacing tokens with their regex expressions.
	ii = 1;
	while ii <= nTokens
		% Adjust the token positions
		iend   = iend   - istart(ii) + 1;
		istart = istart - istart(ii) + 1;
		
		% Extract the token
		theToken = post(istart(ii)+1:iend(ii));
		
	%------------------------------------%
	% Ignore "%( ... %)"                 %
	%------------------------------------%
		if strcmp(theToken, '(')
			% First character after "%("
			iopen = iend(ii) + 1;
			
			% Find the closing "%)"
			close_str    = cell(1, nTokens);
			close_str(:) = {'%)'};
			iCloseTok    = find( cellfun(@strcmp, tokens, close_str), 1, 'first');
			
			% Last character before "%)"
			iclose = istart(iCloseTok) - 1;
			
			% Whatever is between the parentheses gets moved straight to PRE
			%   Three parts:
			%     1. Prior to token
			%     2. Between "%(" and "%)"
			%     3. After "%)" but before the next token
			%   Must check if "%)" is the last token.
			if iCloseTok == length(iend)
				pre  = [ pre post(iopen:iclose) post( iend(iCloseTok)+1:end )];
				post = '';
			else
				pre  = [pre post(iopen:iclose) post( iend(iCloseTok)+1:istart(iCloseTok+1)-1 )];
				post = post(istart(iCloseTok+1):end);
			end
			
			% Skip to "%)"
			ii = iCloseTok;
		
	%------------------------------------%
	% Replace Token with Regex           %
	%------------------------------------%
		else
			% Create a more informative error message.
			try
				theRegex = token_map(theToken);
			catch errorID
				error( ['Unidentified token: "' theToken '".'] );
			end

			% Append the regular expression to PRE
			pre = [pre theRegex];
			
			% Move to the next token
			if ii < nTokens
				pre  = [pre post(iend(ii)+1:istart(ii+1)-1)];
				post = post(istart(ii+1):end);
			end
		end
		
		% Move on
		ii = ii + 1;
	end
		
%------------------------------------%
% Finalize Results                   %
%------------------------------------%
	% Remainder of the string -- Anything after the last token.
	%   - If the last token is at the end of the string, [] is returned
	%     and POST does not change.
	post = post(iend(end)+1:end);
	
	% Put the two pieces back together
	regex = [pre post];
	
	% Replace "\%" with "%"
	regex = regexprep(regex, '\\%', '%');
end