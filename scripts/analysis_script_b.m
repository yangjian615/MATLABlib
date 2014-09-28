mission = 'C';
sc = '2';
date = '20011001';
tstart = '083000';
tend = '103000';
% ref_time = '094100';        % 20050225
% ref_time = '144000';        % 20050125
ref_time = '084000';        % 20011001
% ref_time = '-1';            % 20120929

start_datenum = datenum(date, 'yyyymmdd');
% xrange = [hms_to_ssm(103740), hms_to_ssm(103820)] / 86400 + start_datenum;  %20050225
% xrange = [hms_to_ssm(094800), hms_to_ssm(094840)] / 86400 + start_datenum;  %20011001
xrange = [hms_to_ssm(144935), hms_to_ssm(145100)] / 86400 + start_datenum;  %20050125
% xrange = [hms_to_ssm(000000), hms_to_ssm(080000)] / 86400 + start_datenum;  %20120929



%%%%%%%%%%%%%%%%
% Merge the data 
%%%%%%%%%%%%%%%%
myObj = fg_sc_merge;
myObj.ref_time = ref_time;
[t_merge, b_merge] = myObj.merge(mission, sc, date, tstart, tend);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Despin and Rotate to GSE %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b_merge_despun = myObj.despin(t_merge, b_merge);
b_merge_gse = myObj.scs_to_gse(t_merge, b_merge_despun);
clear b_merge_despun

b_fgm_despun = myObj.despin(myObj.t_fgm, myObj.b_fgm);
b_fgm_gse = myObj.scs_to_gse(myObj.t_fgm, b_fgm_despun);
clear b_fgm_despun

% Must rotate SCM to the FGM frame for the despinning to work...
cobj = cluster_data_merge();
cobj.inst = 'FGM';
cobj.sc = sc;
cobj.get_rotmat_to_scm_frame;
cobj.get_amp_factor
b_scm_inFGMframe = (myObj.b_scm*cobj.amp_factor) * cobj.rotmat_to_scm';
b_scm_despun = myObj.despin(myObj.t_scm, b_scm_inFGMframe);
b_scm_despun = b_scm_despun * cobj.rotmat_to_scm;
b_scm_gse = myObj.scs_to_gse(myObj.t_scm, b_scm_despun);
clear cobj rot_mat b_scm_inFGMframe b_scm_despun

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Minimum variance frame %
%%%%%%%%%%%%%%%%%%%%%%%%%%

% C2 20050225
% eigvecs = [ 0.7281,  0.3183,  0.6071; ...
%            -0.3564,  0.9323, -0.0614; ...
%            -0.5855, -0.1717,  0.7923];

% eigvecs = [ 0.0657,  0.7884, -0.6117; ...
%            -0.0565,  0.6150,  0.7865; ...
%             0.9962, -0.0172,  0.0850];
% eigvecs = flipud(eigvecs);                  %Magnetotail Z-->N, X-->L

% C3 20011001
eigvecs = eye(3);

% C1 20050125
% eigvecs = [ 0.8451,  0.2598,  0.4673; ...
%            -0.3757,  0.9104,  0.1732; ...
%            -0.3804, -0.3219,  0.8670];

% C2 20050125
% eigvecs = [ 0.8470,  0.3174,  0.4264; ...
%            -0.4596,  0.8404,  0.2871; ...
%            -0.2672, -0.4392,  0.8577];

% C4 20050125       
% eigvecs = [ 0.8589, -0.4148,  0.3005; ...
%             0.3040,  0.8850,  0.3526; ...
%            -0.4122, -0.2115,  0.8862];

       
b_merge_lmn = (eigvecs * b_merge_gse')';
b_fgm_lmn = (eigvecs * b_fgm_gse')';
% clear b_merge_gse b_fgm_gse b_scm_gse

%%%%%%%%%%%%%%%%%%%
% Filter the Data %
%%%%%%%%%%%%%%%%%%%

% Uses workspace
dt_filter



%%%%%%%%%%%%%%
% MAKE PLOTS %
%%%%%%%%%%%%%%

% convert the times to date numbers
% t_merge = start_datenum + t_merge/86400;
% t_fgm = start_datenum + myObj.t_fgm/86400;
% t_scm = start_datenum + myObj.t_scm/86400;
% 
% comp_fgm_merge
%