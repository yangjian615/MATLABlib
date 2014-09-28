%**************************************************************************
% NAME:
%       MrCDF_EpochType
%
% PURPOSE:
%   Determine the type of CDF Epoch
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
%   EPOCH_TYPE:     CDF Epoch type.
%
%**************************************************************************
function [epoch_type] = MrCDF_EpochType(epoch)
    
    % Determine the datatype of the epoch value
    datatype = class(epoch);

    % What is the epoch type
    switch class(epoch)
        case 'double'
            % EPOCH
            if isreal(epoch)
                epoch_type = 'CDF_EPOCH';

            % EPOCH 16
            else
                epoch_type = 'CDF_EPOCH16';
            end
            
        case 'int64'
            epoch_type = 'CDF_TIME_TT2000';
            
        otherwise
            error(['Datatype "', datatype, '" is not a valid CDF Epoch type.']);
    end
end