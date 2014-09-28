%**************************************************************************
% NAME:
%       MrCDF_EpochToDatenum
%
% PURPOSE:
%   Convert any CDF epoch type to MatLab datenum. This function serves as
%   a wrapper for the following functions:
%       epochtodatenum
%       epoch16todatenum
%       tt2000todatenum
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
%   DATENUM:        Datenum corresponding to `EPOCH`.
%
%**************************************************************************
function [datenum] = MrCDF_EpochToDatenum(epoch, type)
    
    % Determine the epoch type if it was not given
    if nargin() == 1
        type = MrCDF_EpochType(epoch(1));
    end
    
    % Breakdown the epoch value
    switch type
        case 'CDF_EPOCH'
            datenum = epochtodatenum(epoch);
            
        case 'CDF_EPOCH16'
            datenum = epoch16todatenum(epoch);
            
            
        case 'CDF_TIME_TT2000'
            datenum = tt2000todatenum(epoch);
            
        otherwise
            error('Input TYPE must be "CDF_EPOCH", "CDF_EPOCH16" or "CDF_TIME_TT2000".')
    end
end