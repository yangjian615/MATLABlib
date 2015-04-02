kernel = '/Users/argall/Documents/External_Libraries/Spice/rbsp_current_argall.txt';
cspice_furnsh(kernel);
%
% NOTES ABOUT EPOCHS AND CLOCKS (in regards to the SPICE toolkit):
%
%   ET
%       Ephemeris seconds past J2000.
%
%       "There are two forms of ephemeris time:
%           Barycentric Dynamical Time (TDB) and 
%           Terrestrial Dynamical Time (TDT).
%        Although they represent different time systems, these time systems are
%        closely related. When ephemeris time is called for by Toolkit routines,
%        TBD is the implied time system."
%
%       "Atomic time (TAI) is simply a count of atomic
%        seconds that have occurred since the astronomically determined instant
%        of midnight January 1, 1958 00:00:00"
%
%       "Coordinated Universal Time is a system of time keeping that gives a name
%        to each instant of time of the TAI system."
%
%       "TDT and TAI change at the same rate. Thus the difference between TDT and TAI is
%        a constant. It is defined to be 32.184 seconds."
%
%       "There is an important distinction between the names given to ephemeris
%        seconds and the names used by the UTC system. The names assigned to
%        ephemeris times never have leap seconds."
%
%
%       "If you don't worry about what happens during a leapsecond you can
%        express the above idea as:
%     
%           [4]         DeltaTDT =  TDT - UTC"
%
%       Here,
%
%                       DelatTDT =        DeltaTA        +                 DeltaAT
%                                = (TDT - TAI = 32.184s) + (# leap seconds between TDT and UTC)
%
%       So,
%
%           [7]         TDB - UTC =  DeltaTA + DeltaAT + K*sin(E)
%
%
%
%       "Julian Ephemeris Date is computed directly from ET via the formula
%        
%             jed = cspice_j2000 + et/cspice_spd;
%
%        Julian Date UTC has an integer value whenever the corresponding UTC time
%        is noon.
%       
%        We recommend against using the JDUTC system as it provides no mechanism
%        for talking about events that might occur during a leapsecond. All of
%        the other time systems discussed can be used to refer to events
%        occurring during a leap second."
%
%       
%
%   MET (Mission Elapsed Time) 
%       spacecraft clock seconds since 1/1/2010 00:00:00.0 UTC
%
%       NOTE: MET time stored in CDF files have been converted to decimal
%             fractions of a clock second. I.e. an MET time of 
%
%                           1 / 90547201:43502
%
%             Reads
%
%                             90547201.87004
%
%             within the CDF file. This is because the MET time '0:50000'
%             corresponds to '1:00000', i.e. there are 50,000 clock ticks
%             in one clock second. To turn these into decimal seconds, all
%             one needs to do is multiply by 2.
%
%             To convert from CDF MET to real MET values, one must divide
%             the fractional MET by 2.
%
%   CDF_TIME_TT2000
%       Number of nanoseconds since J2000.
%
%       "Time_Scale = Terrestrial Time (TT)", i.e. TDT in the context of CSPICE
%
%       "conversion between TT and UTC is straightforward
%           TT = TAI + 32.184s; 
%           TT = UTC + deltaAT + 32.184s
%       where deltaAT is the sum of the leap seconds since 1960"
%
%
%   UTC
%       Despite what wikipedia says,
%           "The current version of UTC is ... based on International Atomic Time (TAI) 
%            with leap seconds added at irregular intervals to compensate for the slowing
%            of Earth's rotation."
%       UTC does **NOT** include leap seconds, at least as far as CSPICE and CDFLIB are
%       concerned. I.e,
%
%           CSPICE
%               UTC = TDT - deltaTA - deltaAT
%                   = TDT - 32.184  - (# Leap Seconds)
%               UTC = TDB - 32.184  - (# Leap Seconds) - K*sin(E)
%
%           CDFLIB
%               UTC = CDF_TT2000_TIME - 32.184  - (# Leap Seconds)
%                   = TDT             - 32.184  - (# Leap Seconds)
%
%
%   DateNum
%       Serial date in days since 1/0/0000.
%       Does not count leapseconds.
%
%
%   Julian Day 
%       Number of whole and partial days after 1/1/4713BC 12:00:00.0
%
%
%   J2000
%       Elapsed seconds since 2000-01-01 12:00:00 UTC.
%       J2000 = Julian Day 2451545.0
%
%
% 	RBSP SPACECRAFT CLOCK
%
%       "One part, called iMET or IMET, represents the integer
%        number of seconds since the start epoch of midnight (00:00:00 UTC)
%        on January 1st, 2010. The second part, called vMET or VMET, 
%        represents sub-seconds in units of clock ?ticks,? each such tick 
%        lasting 1/50,000th of an IMET second, or about 20 ms."
%
%
%       "In a particular partition of the RBSP spacecraft clock,
%        the clock read-out consists of two separate stages:
% 
%                            1/18424652:24251
% 
%        The first stage, a 32 bit field, represents the spacecraft
%        clock seconds count.  The second, a 16 bit field, represents
%        counts of 20 microsecond increments of the spacecraft clock."
%
% REFERENCES:
%   CDF_TIME_TT2000
%       http://cdf.gsfc.nasa.gov/html/leapseconds.html
%   SPICE's idea of time (time.req)
%       http://naif.jpl.nasa.gov/pub/naif/toolkit_docs/MATLAB/req/time.html
%   Spacecraft Clock Time
%       http://link.springer.com/article/10.1007%2Fs11214-012-9949-2
%       http://link.springer.com/content/pdf/10.1007%2Fs11214-012-9949-2
%       https://github.com/mattbornski/spice/blob/master/examples/rbspa_sample_0000.tsc
%   MatLab CDF Patch (includes list of new functions for ">> help ...")
%       http://cdf.gsfc.nasa.gov/html/matlab_cdf_patch3410.html
%   CSPICE Toolkit
%       http://naif.jpl.nasa.gov/naif/toolkit.html
%   CSPICE Toolkit Documentation (c.f. Mice API Reference Guide)
%       http://naif.jpl.nasa.gov/pub/naif/toolkit_docs/MATLAB/index.html
%       
%
% PURPOSE:
%
%   The goal here is to try different time-conversion functions using
%   SPICE. Some work is still needed in formatting the displayed outputs...
%
% EXAMPLES:
%   1. Converting TT2000
%       A. to [YYYY MM DD HH MM SS mmm uuu nnn]
%       B. Datenum
%       C. Check Datenum
%       D. J2000
%       E. UTC
%   2. Converting MET
%       A. ET
%       B. Double
%       C. nTicks to ET
%   3. Converting ET
%       A. nTicks
%       B. MET
%       C. UTC
%           - Calendar Date
%           - Julian Date
%           - ISOC Date
%           - ISOD Date
%       D. UTC via deltaET
%       E. Calendar String (no leap seconds)
%       F. Solar Time on Surface of a Body
%   4. Converting ticks
%       A. to MET
%   5. Converting Epoch Strings
%       A. to ET
%   6. Illustrate that MatLab's 'datenum' function does not handle leap
%       seconds
%   7. Check Conversions
%       A. TT2000 --> UTC --> ET --> MET --> UTC
%       B. MET    ----------> ET ----------> UTC
%
% INCLUES:
%   cspice_scs2e
%   cspice_sct2e
%   cspice_scendcd
%   cspice_sce2c
%   cspice_sctiks
%   cspice_sce2s
%   cspice_str2et
%   cspice_timeout
%   cspice_et2utc
%   cspice_etcal
%   cspice_et2lst
%   cspice_tpictr
%   cspice_deltaet
%
% DOES NOT INCLUDE:
%   cspice_tsetyr
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% LEAP SECOND TABLE:
%-------------------------------------------------------------------------%
%     	     	     	  Leap 		 Drift		 Drift
% Year	Month	  Day	Seconds		 1           2
% 1960	  1	       1	1.41782		 37300		 0.001296
% 1961	  1	       1	1.42282		 37300		 0.001296
% 1961	  8	       1	1.37282		 37300		 0.001296
% 1962	  1	       1	1.84586		 37665		 0.0011232
% 1963	  11	   1	1.94586		 37665		 0.0011232
% 1964	  1	       1	3.24013		 38761		 0.001296
% 1964	  4	       1	3.34013		 38761		 0.001296
% 1964	  9	       1	3.44013		 38761		 0.001296
% 1965	  1	       1	3.54013		 38761		 0.001296
% 1965	  3	       1	3.64013		 38761		 0.001296
% 1965	  7	       1	3.74013		 38761		 0.001296
% 1965	  9	       1	3.84013		 38761		 0.001296
% 1966	  1	       1	4.31317		 39126		 0.002592
% 1968	  2	       1	4.21317		 39126		 0.002592
% 1972	  1	       1	10           0           0
% 1972	  7	       1	11           0           0
% 1973	  1	       1	12           0           0
% 1974	  1	       1	13           0           0
% 1975	  1	       1	14           0           0
% 1976	  1	       1	15           0           0
% 1977	  1	       1	16           0           0
% 1978	  1	       1	17           0           0
% 1979	  1	       1	18           0           0
% 1980	  1	       1	19           0           0
% 1981	  7	       1	20           0           0
% 1982	  7	       1	21           0           0
% 1983	  7	       1	22           0           0
% 1985	  7	       1	23           0           0
% 1988	  1	       1	24           0           0
% 1990	  1	       1	25           0           0
% 1991	  1	       1	26           0           0
% 1992	  7	       1	27           0           0
% 1993	  7	       1	28           0           0
% 1994	  7	       1	29           0           0
% 1996	  1	       1	30           0           0
% 1997	  7	       1	31           0           0
% 1999	  1	       1	32           0           0
% 2006	  1	       1	33           0           0
% 2009	  1	       1	34           0           0
% 2012	  7	       1	35           0           0
%-------------------------------------------------------------------------%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THE FOLLOWING INFORMATION WILL BE USED IN ALL EXAMPLES UNLESS
% OTHERWISE NOTED:
%
% - The TT2000 time corresponding to 2012-11-14 00:00:00.619908273
% - The MET time corresponding to ---^
% - RBSP-A's NAIF ID number is -382
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

t_tt2000 = 406123267803908273;
t_cdfMET = 90547201.87005;
A_ID = -362;

%-------------------------------------------------------------------------%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXAMPLE 1: Convert TT2000 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   A. to [YYYY MM DD HH MM SS mmm uuu nnn]
t_hms = breakdowntt2000(t_tt2000);

%   B. to Datenum
t_hms(6) = t_hms(6) + t_hms(7)*1e-3 + t_hms(8)*1e-6 + t_hms(9)*1e-9;
t_hms_to_datenum = datenum(t_hms(1:6));

%   C. Check Datenum
t_hrs = fix(mod(t_hms_to_datenum, 1) * 24);
t_min = fix(mod(mod(t_hms_to_datenum, 1) * 24, 1) * 60);
t_sec = mod(mod(mod(t_hms_to_datenum, 1) * 24, 1) * 60, 1) * 60;
t_datnum_to_hms = [t_hrs t_min t_sec];

%   D. to J2000
t_tt2000_to_j2000 = double(t_tt2000) * 1e-9;

%   E. to UTC (35 leap seconds)
t_tt2000_to_UTC = t_tt2000_to_j2000 - 35 - 32.184;

% Print Results
disp('------------- EXAMPLE 1: Convert TT2000 --------------')
str1 = sprintf('TT2000:                %i', t_tt2000);
str2 = sprintf('TT2000    BrkDwn:      %04i-%02i-%02i %02i:%02i:%012.9f', t_hms(1:6));
str3 = sprintf('TT2000 to DATNUM:      %f', t_hms_to_datenum);
str4 = sprintf('TT2000 to J2000:       %f', t_tt2000_to_j2000);
str5 = sprintf('TT2000 to UTC:         %f\n', t_tt2000_to_UTC);
disp(char(str1, str2, str3, str4, str5));

clear t_hms_to_datenum t_hrs t_min t_sec t_datenum_to_hms ...
      t_tt2000_to_j2000 str1 str2 str3 str4
% PRESERVE t_hms

%-------------------------------------------------------------------------%
  
%%%%%%%%%%%%%%%%%%%%%%%%%
% EXMPLE 2: Convert MET %
%%%%%%%%%%%%%%%%%%%%%%%%%
%   1. to ET
iMET = num2str(fix(t_cdfMET));
vMET = num2str(fix(mod(t_cdfMET, 1)/2 * 1e5));
strMET = ['1 / ' iMET ':' vMET];
t_MET_to_ET = cspice_scs2e(A_ID, strMET);

%   3. to DOUBLE
t_MET_to_Double = cspice_scencd(A_ID, strMET);

%   4. to nTicks (do not include partition number)
t_MET_to_nTicks = cspice_sctiks(A_ID, strMET(5:end));

% Print results
disp('--------------- EXAMPLE 2: Convert MET ---------------')
str1 = sprintf('MET:                   %s', strMET);
str2 = sprintf('MET    to ET:          %f', t_MET_to_ET);
str3 = sprintf('MET    to Double:      %d', t_MET_to_Double);
str4 = sprintf('MET    to nTicks:      %i\n', t_MET_to_nTicks);
disp(char(str1, str2, str3, str4));

clear intMET fracMET t_MET_to_Double str1 str2 str3 str4
% PRESERVE: strMET, t_MET_to_ET t_MET_to_nTicks

%-------------------------------------------------------------------------%

%%%%%%%%%%%%%%%%%%%%%%%%%
% EXAMPLE 3: Convert ET %
%%%%%%%%%%%%%%%%%%%%%%%%%

%   A. to nTicks
t_ET_to_nticks = cspice_sce2c(A_ID, t_MET_to_ET);

%   B. to MET
t_ET_to_MET = cspice_sce2s(A_ID, t_MET_to_ET);

%   C. to string
sample = '2005/01/22 03:12:52.123456789';
pictur = cspice_tpictr(sample);
t_ET_to_string = cspice_timout(t_MET_to_ET, pictur);

%   D. to UTC
t_ET_to_UTC_C = cspice_et2utc(t_MET_to_ET, 'C', 9);
t_ET_to_UTC_D = cspice_et2utc(t_MET_to_ET, 'D', 9);
t_ET_to_UTC_J = cspice_et2utc(t_MET_to_ET, 'J', 9);
t_ET_to_UTC_ISOC = cspice_et2utc(t_MET_to_ET, 'ISOC', 9);
t_ET_to_UTC_ISOD = cspice_et2utc(t_MET_to_ET, 'ISOD', 9);

%   E. to UTC via deltaet
t_deltaET = cspice_deltet(t_MET_to_ET, 'ET');

%   F. to Calendar string (no leap seconds).
t_ET_to_CAL = cspice_etcal(t_MET_to_ET);

%   F. to Solar time on the surface of a body
body = 499;                 % Mars
lon = 326.17 * cspice_rpd;  % longitude on Mars
type = 'PLANETOCENTRIC';    % or 'PLANETOGRAPHIC'
[hrBody, mnBody, secBody, timeBody, ampmBody] ...
    = cspice_et2lst(t_MET_to_ET, body, lon, type);

% Print results
disp('--------------- EXAMPLE 3: Convert ET ----------------')
strA = sprintf('ET:                    %012.9f', t_MET_to_ET);
str1 = sprintf('ET     to nticks:      %013.0f', t_ET_to_nticks);
str2 = sprintf('ET     to MET:         %s', t_ET_to_MET);
str3 = sprintf('ET     to string:      %s', t_ET_to_string);
str4 = sprintf('ET     to UTC C:       %s', t_ET_to_UTC_C);
str5 = sprintf('ET     to UTC D:       %s', t_ET_to_UTC_D);
str6 = sprintf('ET     to UTC J:       %s', t_ET_to_UTC_J);
str7 = sprintf('ET     to UTC ISOC:    %s', t_ET_to_UTC_ISOC);
str8 = sprintf('ET     to UTC ISOD:    %s', t_ET_to_UTC_ISOD);
str9 = sprintf('ET     to UTC deltaET: %d', t_deltaET);
str0 = sprintf('ET     to UTC CAL:     %s\n', t_ET_to_CAL);
disp(char(strA, str1, str2, str3, str4, str5, str6, str7, str8, str9, str0));

clear t_ET_to_nticks t_ET_to_MET sample pictur t_ET_to_string ...
      t_ET_to_UTC_C t_ET_to_UTC_D t_ET_to_UTC_J t_ET_to_UTC_ISOC t_ET_to_UTC_ISOD ...
      t_deltaET t_ET_to_CAL body lon type hrBody mnBody secBody timeBody ...
      ampmBody strA str1 str2 str3 str4 str5 str6 str7 str8 str9 str0
% PRESERVE: t_hms strMET, t_MET_to_ET t_MET_to_nTicks

%-------------------------------------------------------------------------%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXAMPLE 4: Convert nTicks %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   1. to ET
t_nTicks_to_ET = cspice_sct2e(A_ID, t_MET_to_nTicks);

disp('------------- EXAMPLE 4: Convert nTicks --------------')
str1 = sprintf('nTicks:                %013.0f', t_MET_to_nTicks);
str2 = sprintf('nTicks to ET:          %012.9f\n', t_nTicks_to_ET);
disp(char(str1, str2));

clear t_nticks_to_MET str1 str2 t_MET_to_nTicks
% PRESERVE: t_hms strMET, t_MET_to_ET

%-------------------------------------------------------------------------%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXAMPLE 5: Convert Epoch Strings %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

t_strhms = [num2str(t_hms(1), '%4i'), '-', num2str(t_hms(2), '%02i'), '-', ...
            num2str(t_hms(3), '%02i'), 'T', num2str(t_hms(4), '%02i'), ':', ...
            num2str(t_hms(5), '%02i'), ':', num2str(t_hms(6), '%012.9f')];
        
%   A. to_ET
t_str_to_ET = cspice_str2et(t_strhms);

% Print results
disp('---------- EXAMPLE 5: Convert Epoch Strings ----------')
str1 = sprintf('String:                %s'    , t_strhms);
str2 = sprintf('String to ET:          %011.5f\n', t_str_to_ET);
disp(char(str1, str2));

clear t_hms t_strhms t_str_to_ET str1 str2
% PRESERVE: strMET, t_MET_to_ET

%-------------------------------------------------------------------------%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXAMPLE 6: Illustrate Leapseconds %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Leap seconds were applied on 2012-06-30 23:59:60 and 2008-12-31 23:59:60 UTC
LeapSecond = '2012-06-30T23:59:60.000000000';
LeapArray = [2012, 06, 30, 23, 59, 60, 000, 000, 000, 000];
TimeArray = [2012, 06, 30, 23, 59, 59, 000, 000, 000, 000];

% Compute the different CDF EPOCH-type values
%     cdflib.computeEpoch produces an error when called with 60 in the seconds column
%     cdflib.computeEpoch16 produces an error when called with 60 in the seconds column
%
% Given the above, we will compute the Epoch value for 2012-06-30 23:59:59 then add one
% second to the answer to see what happens.
cdf_epoch = cdflib.computeEpoch([TimeArray(1:7)]) + 1000;   % 1000ms in 1s
cdf_epoch16 = cdflib.computeEpoch16(TimeArray) + [1; 0];    % 1s and 0ps
cdf_tt2000 = computett2000([LeapArray(1:9)]);

% Convert the CDF EPOCH-type values to strings
str_epoch = parse_cdf_epoch(cdf_epoch);
str_epoch16 = parse_cdf_epoch(cdf_epoch16);
str_tt2000 = parse_cdf_epoch(cdf_tt2000);

% Convert the Leapseconds time to a datenumber, then back to a string
LeapDateNum = datenum(LeapArray(1:6));
StrDateNum = datestr(LeapDateNum, 31);

disp('-------- EXAMPLE 6: Examine Leap Seconds ---------')
disp('Convert a TT2000 Leapsecond date to a date number.')
str1 = sprintf('Input  =           DATE:  %s', LeapSecond);
str2 = sprintf('Output =          EPOCH:  %s', str_epoch);
str3 = sprintf('Output =        EPOCH16:  %s', str_epoch16);
str4 = sprintf('Output =         TT2000:  %s', str_tt2000);
str5 = sprintf('Output = MatLab Datestr:  %s\n', StrDateNum);
disp(char(str1, str2, str3, str4, str5));

clear LeapSecond LeapDateNum StrDateNum str1 str2 str3 str4 str5 str6

% TT2000 time are nanoseconds since 1/1/2000 12:00 noon.
% MatLab Date Numbers are fractional days since 1/1/0000 0:00:00.
% Subtract the difference in start times so that the serial time is shifted
% to the TT2000 time.
%%%%%%%%%%
% tt2000_epochDateNum = datenum(2000, 1, 1, 12, 0, 0.0);
% LeapDateNum = datenum(2012, 12, 31, 23, 59, 60);
% LeapDateTT2000 = (LeapDateNum - tt2000_epochDateNum) * 86400.0;
% decimal_difference = LeapDateTT2000 - tt2000*1e-9;
% 
% str1 = sprintf('Decimal Difference: %f\n', decimal_difference);
% disp(char(str1));
% 
% clear tt2000 tt2000_epochDateNum LeapDateNum LeapDateTT2000 ...
%       decimal_difference str1
% PRESERVE: t_hms strMET, t_MET_to_ET

%-------------------------------------------------------------------------%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXAMPLE 7: Convert TT2000 to ET %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the number of nano seconds between 
%   a) 2000-01-01T12:00:00.000000000
%   b) 2012-06-30T23:59:60.000000000
% There are 4563.5 days between midnight on the above to dates .
%   - c.f. http://www.timeanddate.com/date/duration.html
% Add in 86399 seconds to get to 23:59:59.000 
% Plus 34 leap seconds before date b)
% Plus 01 leap seconds to get to 23:59:60.000
% Plus 32.184 to convert from TDT to TAI
t_tt2000 = (int64(4563.5*86400) + int64(86399) + int64(35))*int64(1e9) + int64(32.184 * 1e9);
tt2000_string = parse_cdf_epoch(tt2000);

% Do the same for UTC (no leap seconds or 32.184 correction)
% This should be the number of UTC seconds between times "a" and "b" above.
t_UTC = 4563.5*86400.0 + 86400.0;

% Convert TT2000 to UTC. 
t_tt2000_to_UTC = double(t_tt2000)*1e-9 - 34.0 - 32.184;

% Calculate ET - UTC = deltaET
% Convert  (TT2000 -->) UTC to ET
% Find the (TT2000 -->) UTC time as a date string
% Convert  (TT2000 -->  UTC -->) ET to MET
t_deltaET = cspice_deltet(t_tt2000_to_UTC, 'UTC');
t_tt2000_to_ET = t_tt2000_to_UTC + t_deltaET;
t_tt2000_to_UTC2 = cspice_et2utc(t_tt2000_to_ET, 'C', 9);
t_tt2000_to_MET = cspice_sce2s(A_ID, t_tt2000_to_ET);

% Convert the MET time to ET
t_MET_to_ET = cspice_scs2e(A_ID, t_tt2000_to_MET);

% Convert (MET -->) ET to Julian UTC
t_ET_to_UTC = cspice_et2utc(t_MET_to_ET, 'C', 9);

% Print the results
disp('-------------- EXAMPLE 7: TT2000 to ET ---------------')
str1  = sprintf('TT2000 (Calculated):  %018d', t_tt2000);
str2  = sprintf('UTC (Calculated):     %018.9f', t_UTC);
str3  = sprintf('TT2000 String:        %s', tt2000_string);
str4  = sprintf('TT2000 to UTC:        %012.9f', t_tt2000_to_UTC);
str5  = sprintf('UTC    to ET:         %012.9f', t_tt2000_to_ET);
str6  = sprintf('ET     to MET:        %s', t_tt2000_to_MET);
str7  = sprintf('ET     to UTC:        %s\n', t_tt2000_to_UTC2);
str8  = sprintf('MET:                  %s', strMET);
str9  = sprintf('MET    to ET:         %012.9f', t_MET_to_ET);
str10 = sprintf('ET     to UTC:        %s', t_ET_to_UTC);
disp(char(str1, str2, str3, str4, str5, str6, str7, str8, str9, str10));

clear t_tt2000 t_tt2000_to_ns t_tt2000_to_s ...
      t_tt2000_to_tt2ks t_tt2000_to_UTC t_deltaET t_tt2000_to_ET ...
      t_tt2000_to_UTC2 t_tt2000_to_MET t_MET_to_ET t_ET_to_UTC ...
      str1 str2 str3 str4 str5 str6 str7 str8 str9 str10
% PRESERVE: t_hms, strMET, t_MET_to_ET

cspice_kclear;
