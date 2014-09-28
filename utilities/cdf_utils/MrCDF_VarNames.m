%**************************************************************************
% NAME:
%       MrCDF_VarNames
%
% PURPOSE:
%   Return names of variables contained within a CDF file.
%
% CALLING SEQUENCE:
%   MrCDF_VarNames(filename);
%       Print variable names to the command window
%
%   varnames = MrCDF_VarNames(filename);
%       Return a cell array of variable names.
%
% :Params:
%   FILENAME:       in, required, type=string
%                   Name of the CDF file for which the variable names are
%                       to be returned.
%
% :Returns:
%   VARNAMES:       Cell array of variable names.
%
%**************************************************************************
function [varnames] = MrCDF_VarNames(filename)

    % Make sure th file exists
    assert( exist(filename, 'file') == 2, ['File does not exist: ', filename]);
    
    % Open the file
    cdfID = cdflib.open(filename);
    
    % Figure out how many variables are in the file
    %   - info.numVars
    info = cdflib.inquire(cdfID);
    
    % Allocate memory
    varnames = cell(1,info.numVars);
    
    % Get all variable names
    for ii = 0 : info.numVars-1
        varinfo        = cdflib.inquireVar(cdfID, ii);
        varnames{ii+1} = varinfo.name;
    end
    
    % Close the CDF file
    cdflib.close(cdfID)
    
    % Print the results if no output is present
    if nargout() == 0
        for ii = 1 : info.numVars
           disp(varnames{ii});
        end
    end
end