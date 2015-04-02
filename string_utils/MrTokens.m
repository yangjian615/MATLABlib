%
% Name
%   MrTokens
%
% Purpose
%   Return a character array of known tokens.
%
%   LIST OF TOKENS::
%       %Y      -   Four-digit year: 2012, 2013, etc.
%       %y      -   Two-digit year: 60-59
%       %M      -   Two-digit month: 01-12
%       %C      -   Calendar month: January, Feburary, etc.
%       %c      -   Abbreviated calendar month: Jan, Feb, etc.
%       %d      -   Day of month: 01-31
%       %D      -   Day of year: 000-366
%       %W      -   Week day: Monday, Tuesday, etc.
%       %w      -   Abbreviated week day: Mon, Tue, etc.
%       %H      -   Hour on a 24-hour clock: 00-24
%       %h      -   Hour on a 12-hour clock: 01-12
%       %m      -   Minute: 00-59
%       %S      -   Seconds: 00-60
%       %f      -   Fraction of a second. Decimal point followed by any number of digits.
%       %z      -   Time Zone, abbreviated name (e.g. EST, CST)
%       %o      -   Offset from UTC: (+|-)hh[:mm] (e.g. +00, +00:00, -01:30)
%       %1      -   Milli-seconds: 000-999
%       %2      -   Micro-seconds: 000-999
%       %3      -   Nano-seconds: 000-999
%       %4      -   Pico-seconds: 000-999
%       %A      -   A.M. or P.M. on a 12-hour clock
%       %?      -   A single, unknown character
%       \%      -   The "%" character
%       %(      -   Text is copied verbatim from "%(" until "%)"
%       %)      -   Text is copied verbatim from "%(" until "%)"
%
%   PROGRAMS & ROUTINES THAT USE TOKENS::
%       MrTokens_ToRegex.pro
%       MrTokens_Extract.pro
%       MrFile_Search.pro
%
% Calling Sequence
%   [TOKENS] = MrTokens()
%     Return an array of tokens known to other MrTokens routines.
%
%   [TOKENS, NTOKENS] = MrTokens()
%     Also return the number of tokens.
%
%   [__] = MrTokens('ParamName', ParamValue)
%     Any valid parameter name-value pair given below.
%
% Parameters
%   'IgnoreParens'    in, optional, type=boolean, default=false
%                     If set, the "(" and ")" tokens will not be included
%                       in the output array.
%
% Returns
%   TOKENS            out, required, type=Nx1 char
%   NTOKENS           out, optional, type=integer
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-03-31      Written by Matthew Argall
%
function [tokens, nTokens] = MrTokens(varargin)

	% Ignore parentheses
	ignore_parens = false;

	% Optional arguments
	nOptArgs = length(varargin);
	for ii = 1 : 2 : nOptArgs
		switch varargin{ii}
			case 'IgnoreParens'
				ignore_parens = varargin{ii+1};
			otherwise
				error( ['Parameter not recognized "' varargin{ii} '".'] );
		end
	end

	% Array of tokens
	tokens = ['Y' 'y' 'M' 'C' 'c' 'd' 'D' 'W' 'w' 'z' 'o' ...
	          'H' 'h' 'm' 'S' 'f' '1' '2' '3' '4' 'A' '?'];

	% Add parentheses
	if ~ignore_parens
		tokens = [tokens '(' ')'];
	end
	
	% Count the tokens
	if nargout == 2
		nTokens = size(tokens);
		nTokens = nTokens(1);
	end
end