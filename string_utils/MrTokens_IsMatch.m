%
% Name
%   MrTokens_IsMatch
%
% Purpose
%   Determine if a MrTokens pattern can be found in a string.
%
% Examples
%   Match a date.
%     >> tf_match = MrTokens_IsMatch('2015-05-13', '%Y-%M-%d')
%        tf_match =
%                    1
%   Match a date within a file name.
%     >> tf_match = MrTokens_IsMatch('mms3_dfg_srvy_l1a_2015051_v0.0.0.cdf', '%Y%M%d')
%        tf_match =
%                    1
%
% Calling Sequence
%   TF_MATCH = MrTokens_IsMatch(STR, PATTERN)
%     Determine if a string STR conforms to the MrTokens pattern PATTERN. PATTERN may
%     contain any token recognized by MrTokens_ToRegex. The regexp() function will
%     check for the first instance of PATTERN within STR.
%
% Parameters
%   STR               in, optional, type=string/cell
%   PATTERN           in, optional, type=string
%
% Returns
%   TF_MATCH          out, required, type=boolean
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-05-13      Written by Matthew Argall
%
function tf_match = MrTokens_IsMatch(str, pattern)

	% Convert the pattern to a regular expression
	regex = MrTokens_ToRegex(pattern);
	
	% Test the regular expression
	tf_match = ~isempty( regexp(str, regex, 'once') );
end