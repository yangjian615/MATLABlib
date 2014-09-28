%**************************************************************************
% NAME:
%       MrC_SCM_TransferFn
%
% PURPOSE:
%   Read transfer function data
%
% CALLING SEQUENCE:
%   [cal_data, cal_freqs] = MrC_SCM_TransferFn();
%   [cal_data, cal_freqs] = MrC_SCM_TransferFn(sc);
%   [cal_data, cal_freqs] = MrC_SCM_TransferFn(sc, directory);
%   [cal_data, cal_freqs] = MrC_SCM_TransferFn(sc, directory, data_product);
%
% :Params:
%   SC:             in, optional, type=char, default='1'
%                   Spacecraft number for which the transfer function is to
%                       be read. Options are: {'1' | '2' | '3' | '4'}
%   DIRECTORY:      in, optional, type=char, default=pwd
%                   Directory in which to search for data.
%   DATA_PRODUCT:   in, optional, type=char
%                   SCM waveform data product to be read, one of {'Hbr' |
%                       'Nbr'}.
%
% :Returns:
%   CAL_DATA:       out, required, type=Nx3 double complex
%                   Amplitude and phase correction for the 3 components of
%                       the uncalibrated SCM magnetic field data.
%   CAL_FREQS:      out, optional, type=double array
%                   Frequencies at which `CAL_DATA` is known.
%
%**************************************************************************
function [cal_data, cal_freqs] = MrC_SCM_TransferFn(sc, directory, data_product)

    % Data product
    if nargin() < 3
        %HBR?
        testfile = fullfile(directory, 'STAFF_SC_Hbr1_X.txt');
        if exist(testfile, 'file') == 1
            data_product = 'Hbr';
        else
            %NBR?
            testfile = fullfile(directory, 'STAFF_SC_Nbr1_X.txt');
            if exist(testfile, 'file') == 1
                data_product = 'Nbr';
            else
                error(['No Hbr or Nbr files found in directory "', directory, '."']);
            end
        end
    end
    
    % Make sure the spacecraft number is a string
    assert(ischar(sc) & max(strcmp(sc, {'1' '2' '3' '4'})), ...
           ['SC "', sc, '" must be a character {"1" | "2" | "3" | "4"}.']);
    

    % Read the data
    components = 'XYZ';
    for ii = 1 : 3
        % Make the file name
        calfile   =  fullfile(directory, ['STAFF_SC_', data_product, sc, '_', components(ii), '.txt']);
        assert(exist(calfile, 'file') == 2, ['File not found: "', calfile, '".']);
        
        % Open and read the file
        fileID    = fopen(calfile);
        temp_data = textscan(fileID, '%f%f%f', ...
                            'MultipleDelimsAsOne', 1, ...
                            'HeaderLines', 23);
        fclose(fileID);

        % Pick out the requencies and data
        if ii == 1
            cal_freqs = temp_data{1};
            cal_data  = complex(temp_data{2}, temp_data{3});
        else
            cal_data  = [cal_data complex(temp_data{2}, temp_data{3})];
        end
    end
    
    % Do not return the frequencies if they are not requrested.
    if nargout == 1
        cal_freqs = [];
    end
end