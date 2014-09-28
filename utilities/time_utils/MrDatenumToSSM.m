%**************************************************************************
% NAME:
%       MrDatenumToSSM
%
% PURPOSE:
%   Convert MATLAB datenumber to seconds since midnight.
%
% CALLING SEQUENCE:
%   t_ssm = MrDatenumToSSM(datenumber);
%
% :Params:
%   DATENUMBER:     in, required, type=double
%                   Scalar or array of MATLAB date numbers.
%
% :Returns:
%   T_SSM:          out, required, type=double
%                   Time, in seconds since midnight.
%
%**************************************************************************
function [t_ssm] = MrDatenumToSSM(datenumber)
    
    % Convert MATLAB datenumber to seconds since midnight
    t_ssm = mod(datenumber, 1) .* 86400;
end