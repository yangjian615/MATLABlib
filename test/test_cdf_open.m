function test_cdf_open

%{
  CAA_read_CDF_CP_EFW_L2_E_*.m
  Filename: 'Cn_CP_EFW_L2_E__*_V110503.cdf'
  'time_tags__C3_CP_EFW_L2_E'                         [1x2 double]    [15000]    'epoch'     'T/'     'Full'
  'E_Vec_xy_ISR2__C3_CP_EFW_L2_E'                     [1x2 double]    [15000]    'single'    'T/T'    'Full'
  'E_bitmask__C3_CP_EFW_L2_E'                         [1x2 double]    [15000]    'int32'     'T/T'    'Full'
  'E_quality__C3_CP_EFW_L2_E'                         [1x2 double]    [15000]    'int32'     'T/T'    'Full'
  'E_Vec_xy_ISR2__C3_CP_EFW_L2_E_REPRESENTATION_1'    [1x2 double]    [    1]    'char'      'F/T'    'Full'
  'E_Vec_xy_ISR2__C3_CP_EFW_L2_E_LABEL_1'             [1x2 double]    [    1]    'char'      'F/T'    'Full'
%}

  clc             % clear the command window
  clear variables % clear all variables
  clear classes
  format compact
  format short g  % +, bank, hex, long, rat, short, short g, short eng

  CAA_data_path          = [pwd, filesep()];
  CAA_EFW_L2_E_data_file = 'rbsp-a_magnetometer_hires-gse_emfisis-L3_20131109_v1.3.3.cdf';
  CAA_EFW_L2_E_data      = [CAA_data_path, CAA_EFW_L2_E_data_file];

  for i = 1: 10

    % Method 1: Using CDF high-level read routines
    % E_Vec_xy_ISR2__C3_CP_EFW_L2_E is a single, and gets stored in MATLAB as a 15000x2 single
    
    EFW_L2_E_DSI = cdfread (CAA_EFW_L2_E_data, ...                             % <n x 2 single>
      'CombineRecords', true, 'Variable', {'Mag'});  % E_field, mV/m, ISR2

    % Method 2: Using CDF lo-level read routines
    % E_Vec_xy_ISR2__C3_CP_EFW_L2_E is a single, and gets stored in MATLAB as a 15000x
    % data = cdflib.hyperGetVarData (cdfId, varNum, recSpec[, dimSpec])
    % CDF record numbers are zero-based.
%     recSpec       = [ 0 15000 1 ]; %  [RSTART RCOUNT RSTRIDE]
%     dimSpec       = {[0.0], [2.0], [1.0]}; % {DSTART DCOUNT DSTRIDE}
%     CDF_L2_E_file = cdflib.open (CAA_EFW_L2_E_data);
%     EFW_L2_E_DSI  = cdflib.hyperGetVarData (CDF_L2_E_file, 1, recSpec, dimSpec)'; % (cdfId, varNum, recSpec[, dimSpec])
%     cdflib.close (CDF_L2_E_file);

  end
end
