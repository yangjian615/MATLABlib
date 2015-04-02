%
% Name
%   mms_dss_despin
%
% Purpose
%   Transform a vector field from a spinning frame to a despun frame.
%
% Examples
%   Extract all tokens.
%     >> [tokens, istart, iend] = MrTokens_Extract('l2g_%((a|b)%)_%Y%M%d')                      
%       tokens = '%('  '%)'  '%Y'  '%M'  '%d'
%       istart =   5    12    15    17    19
%       iend   =   6    13    16    18    20
%
%   Extract tokens, ignoring parentheses:
%     >> [tokens, istart, iend] = MrTokens_Extract('l2g_%((a|b)%)_%Y%M%d', 'IgnoreParens', true) 
%       tokens = '%Y'  '%M'  '%d'
%       istart =  15    17    19
%       iend   =  16    18    20
%
%   Replace a parenthetic expression with '---':
%		  >> [tokens, istart, iend, patternOut] = MrTokens_Extract('l2g_%((a|b)%)_%Y%M%d', 'IgnoreParens', true, 'ReplaceParens', '---')
%       tokens     = '%Y' '%M'  '%d'
%       istart     =   9   11    13
%       iend       =  10   12    14
%       patternOut = l2g_---_%Y%M%d
%
% Calling Sequence
%   [TOKENS] = MrTokens(PATTERN)
%     Extract tokens, TOKENS, recognized by MrTokens from a token pattern,
%     PATTERN.
%
%   [TOKENS, TOK_START, TOK_END] = MrTokens(PATTERN)
%     Return the start and end indiex values into PATTERN at which TOKENS
%     occur.
%
%   [__] = MrTokens(__, 'ParamName', ParamValue)
%     Any valid parameter name-value pair given below.
%     occur.
%
%   [__, PATTERN] = MrTokens(__)
%     If 'ReplaceParens' is used, then output the resulting pattern and
%     adjust TOK_START and TOK_END accordingly.
%
% Parameters
%   'IgnoreParens'    in, optional, type=boolean, default=false
%                     If set, the "%(" and "%)" tokens will not be included
%                       in the output array.
%
% Returns
%   TOKENS            out, required, type=Nx1 char
%   NTOKENS           out, required, type=integer
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-03-31      Written by Matthew Argall
%
function [tokens, tok_start, tok_end, pattern] = MrTokens_Extract(pattern, varargin)

	% Defaults
	ignore_parens  = false;
	replace_parens = '';

	% Optional arguments
	nOptArgs = length(varargin);
	for ii = 1 : 2 : nOptArgs
		switch varargin{ii}
			case 'IgnoreParens'
				ignore_parens = varargin{ii+1};
			case 'ReplaceParens'
				replace_parens = varargin{ii+1};
			otherwise
				error( ['Parameter not recognized "' varargin{ii} '".'] );
		end
	end
	
	%
	% Make sure a single string was given.
	%   - If a cell array is given, TOK_START and TOK_END below are also cells.
	%   - Later, math on cell arrays fails.
	%
	% TODO: Implement cell arrays
	%
	assert( ischar(pattern) && isrow(pattern), 'PATTERN must be a 1xN character array.' )

%------------------------------------%
% Extract Tokens                     %
%------------------------------------%

	% Get all of the known tokens
	allTokens = MrTokens();
	
	% Find all non-escaped tokens within the pattern
	[tokens, tok_start, tok_end] = regexp( pattern, ['(?<!\\)%[' allTokens ']'], 'match');
	nTokens                      = length(tok_start);

%------------------------------------%
% Ignore Parentheses                 %
%------------------------------------%
	if ignore_parens
		
		% Step though the tokens
		ii = 1;
		while ii <= nTokens

			% Find a "%("
			if strcmp( tokens(ii), '%(' )
				iopen = tok_start(ii);
				
				% Find the closing "%)"
				close_str    = cell(1, nTokens-ii);
				close_str(:) = {'%)'};
				tf_close     = cellfun(@strcmp, tokens(ii+1:end), close_str);
				iTokEnd      = find(tf_close, 1, 'first') + 1;
				
				% Make sure a close was found
				if isempty(iTokEnd)
					error( 'Closing token not found: "%)".' )
				end
				iclose = tok_end(iTokEnd);
				
				% If PATTERN is returned, then adjust the pattern as well as the
				% indices at which tokens are found.
				%   - Replace the subexpression with REPLACE_PARENS
				%   - The pattern will be shorter by the length of "%( ... %)", and
				%       longer by the length of REPLACE_PARENS.
				if nargout == 4
					pattern                  = [ pattern(1:iopen-1) replace_parens pattern(iclose+1:end) ];
					tok_start(iTokEnd+1:end) = tok_start(iTokEnd+1:end) - (iclose - iopen + 1) + length(replace_parens);
					tok_end(iTokEnd+1:end)   = tok_end(iTokEnd+1:end)   - (iclose - iopen + 1) + length(replace_parens);
				end
				
				% Remove tokens between "%(" and "%)"
				tokens(ii:iTokEnd)       = [];
				tok_start(ii:iTokEnd)    = [];
				tok_end(ii:iTokEnd)      = [];
				nTokens                  = nTokens - (iTokEnd - ii + 1);
			end
			
			% Move to the next token
			ii = ii + 1;
		end
	end
end