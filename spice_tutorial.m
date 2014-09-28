%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%NAIF IDs for RBSP: naif_ids.req
%NAIF   ID        NAMES
%      -362        'RADIATION BELT STORM PROBE A'
%      -362        'RBSP_A'
%      -363        'RADIATION BELT STORM PROBE B'
%      -363        'RBSP_B'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Frames: frames.req
% Frame Name                Relative To              Type     NAIF ID
% =======================   ===================      =======  =======
% GEI                       J2000                    FIXED    -362900
% GEI_TOD                   J2000                    DYNAMIC  -362901
% GEI_MOD                   J2000                    DYNAMIC  -362902
% MEAN_ECLIP                J2000                    DYNAMIC  -362903
% GEO                       IAU_EARTH                FIXED    -362920
% GSE                       J2000                    DYNAMIC  -362930
% MAG                       J2000                    DYNAMIC  -362940
% GSM                       J2000                    DYNAMIC  -362945
% SM                        J2000                    DYNAMIC  -362950
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Spacecraft-specific frames: /frame_kernel/rbsp[ab]_fk_2012_213.tf
% Frame Name                Relative To              Type      NAIF ID
% =======================   ===================      =======   =======
% 
% Spacecraft Frames (-3620xx):
% ------------------
% RBSPA_SPACECRAFT          J2000                     CK       -362000
% 
% Science Frames    (-3620xx):
% ---------------
% RBSPA_SCIENCE             RBSPA_SPACECRAFT          FIXED    -362050
% 
% Antenna Frames    (-3621xx):
% ---------------
% RBSPA_ANT_POSZ            RBSPA_SPACECRAFT          FIXED    -362110
% RBSPA_ANT_NEGZ            RBSPA_SPACECRAFT          FIXED    -362120
% 
% SSH Frames        (-3621xx):
% ---------------
% RBSPA_SSH_A               RBSPA_SPACECRAFT          FIXED    -362150
% RBSPA_SSH_B               RBSPA_SPACECRAFT          FIXED    -362160
% 
% ECT Frames        (-3624xx):
% ---------------
% 
% EMFISIS Frames    (-3625xx):
% ---------------
% 
% EFW Frames        (-3626xx):
% ---------------
% 
% RBSPICE Frames    (-3627xx):
% ---------------
% 
% RPS Frames        (-3628xx):
% ---------------
% RBSPA_RPS                 RBSPA_SPACECRAFT          FIXED    -362800

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
utc_time = '2012-12-17T12:10:37';
rbspa_clk_epoch = '98799037';

cspice_furnsh('/Users/argall/Documents/External_Libraries/Spice/rbsp_current_argall.txt')

%Convert UTC to Ephemeris Time
et1 = cspice_str2et(utc_time);

%Convert spacecraft clock epoch to ET
et2 = cspice_scs2e(-362, rbspa_clk_epoch);

%Calculate the spacecraft position and velocity with repsect to the sun in
%the Ecliptic frame
target = 'RBSP_A';
frame = 'ECLIPJ2000';
correction = 'NONE';
observer = 'SUN';

starg = mice_spkezr(target, et2, frame, correction, observer);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Compute the apparent direction of the sun in the RBSP A science frame.
target = 'SUN';
frame = 'RBSPA_SCIENCE';
correction = 'LT+S';
observer = 'RBSP_A';

[sundir, ltime] = cspice_spkpos(target, et1, frame, correction, observer);
sundir = cspice_vhat(sundir);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Compute the sub-spacecraft point of RBSP-A in planetocentric longitude and
%latitude.
method = 'NEAR POINT: ELLIPSOID';
target = 'EARTH';
frame = 'IAU_EARTH';
correction = 'NONE';
observer = 'RBSP_A';

%Get the sub-point on the target body-fixed frame. Then convert from
%rectangular to latitude and longitude coordinates.
[spoint, trgepc, srfvec] = cspice_subpnt(method, target, et1, frame, ...
                                         correction, observer);
[srad, slon, slat] = cspice_reclat(spoint);

%Get the coordinates of the sub-point in the RBSP-A Science frame, then the
%direction from the spacecraft to the sub-point in its own frame.
fromfr = 'IAU_EARTH';
tofr = 'RBSPA_SCIENCE';

m2imat = cspice_pxform(fromfr, tofr, et1);
sbpdir = m2imat * srfvec;
sbpdir = cspice_vhat(sbpdir);
sprintf('lon    = %f', slon * cspice_dpr())
sprintf('lat    = %f', slat * cspice_dpr())
sprintf('sbpdir = %f %f %f', sbpdir)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Compute the spacecraft velocity with respect to the earth in the RBSP-A
%Science frame.
target = 'RBSP_A';
frame = 'J2000';
correction = 'NONE';
observer = 'EARTH';

%requires an inertial frame -- the instrument frame
[state, lt] = cspice_spkezr(target, et1, frame, correction, observer);
scvdir = state(4:6);

fromfr = 'J2000';
tofr = 'RBSPA_SCIENCE';

j2imat = cspice_pxform(fromfr, tofr, et1);
scvdir = j2imat * scvdir;
scvdir = cspice_vhat(scvdir);

fprintf('scvdir = %f %f %f', scvdir)


cspice_unload('/Users/argall/Documents/External_Libraries/Spice/rbsp_current_argall.txt')