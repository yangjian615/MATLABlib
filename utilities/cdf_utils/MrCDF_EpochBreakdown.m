%**************************************************************************
% NAME:
%       MrCDF_EpochToDatenum
%
% PURPOSE:
%   Convert any CDF epoch type to MatLab datenum. This function serves as
%   a wrapper for the following functions:
%       cdflib.epochBreakdown
%       cdflib.epoch16Breakdown
%       breakdowntt2000
%
% CALLING SEQUENCE:
%   epoch_type = MrCDF_Epoch(filename);
%       Return the CDF epoch type.
%
% :Params:
%   EPOCH:          in, required, type=any
%                   CDF Epoch time of unknown epoch type.
%   TYPE:           in, optional, type=string
%                   The CDF epoch type of `EPOCH`. If not given, the epoch
%                       type will be determined automatically. CDF Epoch
%                       types and their corresponding MATLAB datatypes
%                       are::
%                           'CDF_EPOCH'         - Double
%                           'CDF_EPOCH16'       - Double complex
%                           'CDF_TIME_TT2000'   - INT64
%
% :Returns:
%   TIMEVEC:        A 10xN array, where N represents the number of elements
%                       in `EPOCH`. The rows contain::
%                           YEAR
%                           MONTH
%                           DAY
%                           HOUR
%                           MINUTE
%                           SECOND
%                           MILLISECOND
%                           MICROSECOND (zeros for CDF_EPOCH)
%                           NANOSECOND  (zeros for CDF_EPOCH)
%                           PICOSECOND  (zeros for CDF_EPOCH and CDF_TIME_TT2000)
%
%**************************************************************************
function [timevec] = MrCDF_EpochBreakdown(epoch, type)
    
    % Determine the epoch type if it was not given
    if nargin() == 1
        type = MrCDF_EpochType(epoch(1));
    end
    
    % Breakdown the epoch value
    switch type
        case 'CDF_EPOCH'
            % Convert from Epoch to Datenum to Datestr
            timevec = cdflib.epochBreakdown(epoch);
            timevec = [timevec; ...
                       zeros(3, length(timevec(1,:)))]; % micro-, nano-, pico-seconds 
            
        case 'CDF_EPOCH16'
            timevec = cdflib.epoch16Breakdown(epoch);
            
            
        case 'CDF_TIME_TT2000'
            timevec = breakdowntt2000(epoch);
            timevec = [timevec; ...
                       zeros(1, length(timevec(1,:)))];	% picoseconds
                       
        otherwise
            error('Input TYPE must be "CDF_EPOCH", "CDF_EPOCH16" or "CDF_TIME_TT2000".')
    end
end