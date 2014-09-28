data_dir = '/Users/argall/Documents/Work/Data/20050125_142500_163500/';

mission = 'C';
sc = '1';
date = '20050125';
tstart = '142500';
tend = '163500';
multiplier = 64;
% ref_time = '094100';        % 20050225
 ref_time = '144000';        % 20050125
% ref_time = '084000';        % 20011001
% ref_time = '-1';            % 20120929

start_datenum = datenum(date, 'yyyymmdd');
% xrange = [hms_to_ssm(103200), hms_to_ssm(104000)] / 86400 + start_datenum;  %20050225
% xrange = [hms_to_ssm(093800), hms_to_ssm(095200)] / 86400 + start_datenum;  %20011001
 xrange = [hms_to_ssm(144700), hms_to_ssm(145200)] / 86400 + start_datenum;  %20050125
% xrange = [hms_to_ssm(000000), hms_to_ssm(080000)] / 86400 + start_datenum;  %20120929



%%%%%%%%%%%%%%%%%%
% Merge the data %
%%%%%%%%%%%%%%%%%%
[t_merge, b_merge, fgm, scm] = fg_sc_merge(mission, sc, date, tstart, tend, ...
                                           'ref_time', ref_time, ...
                                           'multiplier', multiplier, ...
                                           'coord_sys', 'GSE', ...
                                           'fgm_data_dir', data_dir, ...
                                           'scm_data_dir', data_dir);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calibrate SCM Data       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Calibrating...')
b_cal_scm = calibrate_scm(sc, scm.mode, scm.t, scm.b, scm.clen, scm.TransfrFn_dir);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get FGM and SCM Data     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Despinning...')
t_fgm = fgm.t;
b_fgm_despun = fg_sc_despin(fgm.t, fgm.b, mission, sc, date, fgm.attitude_dir, fgm.srt_dir);
b_fgm_gse = fg_sc_scs2gse(fgm.t, b_fgm_despun, mission, sc, date, fgm.attitude_dir, fgm.srt_dir);
clear b_fgm_despun

% Must rotate SCM to the FGM frame for the despinning to work...
t_scm = scm.t;
b_scm_despun = fg_sc_despin(t_scm, b_cal_scm, mission, sc, date, scm.attitude_dir, scm.srt_dir);
b_scm_gse = fg_sc_scs2gse(t_scm, b_scm_despun, mission, sc, date, scm.attitude_dir, scm.srt_dir);
clear b_cal_scm b_scm_despun

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

       
b_merge_lmn = (eigvecs * b_merge')';
b_fgm_lmn = (eigvecs * b_fgm_gse')';
b_scm_lmn = (eigvecs * b_scm_gse')';
clear eigvecs % b_merge b_fgm_gse b_scm_gse

%%%%%%%%%%%%%%%%%%%
% Filter the Data %
%%%%%%%%%%%%%%%%%%%

% Uses workspace
dt_filter
clear fgm scm


%%%%%%%%%%%%%%
% MAKE PLOTS %
%%%%%%%%%%%%%%
disp('Plotting...')
% convert the times to date numbers
t_mg = start_datenum + t_merge/86400;
t_fg = start_datenum + t_fgm/86400;
t_sc = start_datenum + t_scm/86400;
clear start_datenum
% 
% comp_fgm_merge
%
subplot(3,1,1)
plot(t_sc, b_scm_lmn(:,1), t_fg, b_fgm_lmn(:,1), t_mg, b_merge_lmn(:,1))
legend('SCM', 'FGM', 'Merged')
xlim(xrange)

if exist('yrange', 'var') == 1
    ylim(yrange)
end

title(['Comparison between B SCM, FGM and Merged ', date])
xlabel('UT (HH:MM:SS)')
ylabel('Bx (nT) (GSE)')
datetick('x', 'HH:MM:SS', 'keeplimits', 'keepticks')


subplot(3,1,2)
plot(t_sc, b_scm_lmn(:,2), t_fg, b_fgm_lmn(:,2), t_mg, b_merge_lmn(:,2))
legend('SCM', 'FGM', 'Merged')
xlim(xrange)

if exist('yrange', 'var') == 1
    ylim(yrange)
end

title(['Comparison between B SCM, FGM and Merged ', date])
xlabel('UT (HH:MM:SS)')
ylabel('By (nT) (GSE)')
datetick('x', 'HH:MM:SS', 'keeplimits', 'keepticks')


subplot(3,1,3)
plot(t_sc, b_scm_lmn(:,3), t_fg, b_fgm_lmn(:,3), t_mg, b_merge_lmn(:,3))
legend('SCM', 'FGM', 'Merged')
xlim(xrange)

if exist('yrange', 'var') == 1
    ylim(yrange)
end

title(['Comparison between B SCM, FGM and Merged ', date])
xlabel('UT (HH:MM:SS)')
ylabel('Bz (nT) (GSE)')
datetick('x', 'HH:MM:SS', 'keeplimits', 'keepticks')

clear t_mg t_fg t_sc