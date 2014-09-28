clc            % clear the coMMand window
clear all      % clear all variables
format short g % +, bank, hex, long, rat, short, short g, short eng
format compact

records  = 100000; % For 500 000 records, the math is about 2 s; the string conversion makes it 300 s
% method records   time       value
%   1        100   0.01296      17:13:09.123456
%   2        100   0.00100      17:13:09.123456
%   3        100   0.00917      17:13:09.123456
%   4        100   0.01211      17:13:09.123456
%   5        100   0.00628      17:13:09.123456
%   6        100   0.01806      17:13:09.123456
%   7        100   0.00479      17:13:09.123456
%
%   1       1000   0.04868      18:12:15.123456
%   2       1000   0.00104      18:12:15.123456
%   3       1000   0.04119      18:12:15.123456
%   4       1000   0.04030      18:12:15.123456
%   5       1000   0.01587      18:12:15.123456
%   6       1000   0.05027      18:12:15.123456
%   7       1000   0.02043      18:12:15.123456\
%
%   1      10000   0.61033      18:12:15.123456
%   2      10000   0.00123      18:12:15.123456
%   3      10000   0.33688      18:12:15.123456
%   4      10000   0.32989      18:12:15.123456
%   5      10000   0.12715      18:12:15.123456
%   6      10000   0.36017      18:12:15.123456
%   7      10000   0.18821      18:12:15.123456
%
%   1     100000 116.00628      05:17:11.123456
%   2     100000   0.00276      05:17:11.123456
%   3     100000   3.51415      05:17:11.123456
%   4     100000   3.18420      05:17:11.123456
%   5     100000   1.33273      05:17:11.123456
%   6     100000   3.54191      05:17:11.123456
%   7     100000   1.95554      05:17:11.123456

disp('method records   time       value')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ALLOCATE MEMORY \\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ssm      = zeros (records, 1, 'double');
ssm_frac = zeros (records, 1, 'uint32');
ssm_hms  = zeros (records, 1, 'uint32');
ssm_ms   = zeros (records, 1, 'uint16');

HH       = zeros (records, 1, 'uint16');
MM       = zeros (records, 1, 'uint16');
SS       = zeros (records, 1, 'uint16');

sHH      = char (zeros (records, 1, 'uint8') );
sMM      = char (zeros (records, 1, 'uint8') );
sSS      = char (zeros (records, 1, 'uint8') );

strTimes = char (zeros (records, 15, 'uint8') );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERATE TIMES \\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create SSM
ssm      = rand (records, 1);
ssm      = floor (ssm * 24*3600); % matrix of random ssm
ssm      = ssm + 0.123456; % add microseconds
ssm_frac = uint32 ( (ssm - floor (ssm)) * 1e6 );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONVERT TO HMS \\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Break SSM down into hours, minutes, and seconds.
ssm_hms  = uint16 ( floor (ssm) );
HH       = uint16 ( floor (ssm_hms / 3600) );

ssm_ms   = uint16 ( ssm_hms - (HH * 3600) );
MM       = floor (ssm_ms / 60);

SS       = ssm_ms - (MM * 60);

% Strings of the hour, minute, and second
sHH   = num2str (HH, '%02d');
sMM   = num2str (MM, '%02d');
sSS   = num2str (SS, '%02d');

% String of the fractional number of seconds.
sssm_frac   = num2str (ssm_frac, '%06d');

% Clear unnecessary arrays
% clear ssm ssm_frac ssm_hms ssm_ms HH MM SS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% METHOD 1 \\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Horizontally concatenate the hours, minutes, seconds, and fractional seconds.
colon = repmat (':', records, 1);
dot   = repmat ('.', records, 1);

tic
strTimes = strcat (sHH, colon, sMM, colon, sSS, dot, sssm_frac);
speed = toc;

str = sprintf('  1     %6i %9.5f      %s', records, speed, strTimes(1,:));
disp(str);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% METHOD 2 \\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Horizontally concatenate.
tic
strTimes = [sHH, colon, sMM, colon, sSS, dot, sssm_frac];
speed = toc;
str = sprintf('  2     %6i %9.5f      %s', records, speed, strTimes(1,:));
disp(str);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% METHOD 3 \\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write each time to a file.
%   1) Write each time to a file using fprintf.
%   2) Read in each time with textscan.
%   3) Delete the file.
tic
filename = [pwd filesep 'temp_output_test_ssm_to_hms.txt'];
fileID = fopen(filename, 'w+');
for i = 1:records
    fprintf (fileID, '%s:%s:%s.%s\n', sHH(i,:), sMM(i,:), sSS(i,:), sssm_frac(i,:));
end
frewind(fileID);
strTimes = textscan(fileID, '%s');
fclose(fileID);
delete(filename);
speed = toc;
str = sprintf('  3     %6i %9.5f      %s', records, speed, strTimes{1}{1});
disp(str);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% METHOD 4 \\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop 'sprintf' to fill the array.
%   1) Set a precision so that all values have the same number of decimal places.
%   2) Use sprintf to change the numerical values to strings.
%   3) Horizontally concatenate the HH MM SS values
%   *) The loop could be replaced by a '\n' newline at the end
tic
precision = 6;
delimeter = ':';
format_spec = ['%0' num2str(precision+3) '.' num2str(precision), 'f'];
t_hms = cell(1,records);

for ii = 1:records
    t_hms{ii} = [sprintf('%02i', HH(ii)), delimeter, ...
                 sprintf('%02i', MM(ii)), delimeter, ...
                 sprintf(format_spec, SS(ii))];
end
speed = toc;
str = sprintf('  4     %6i %9.5f      %s', records, speed, strTimes{1}{1});
disp(str);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% METHOD 5 \\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Use cellstr to concatenate numerical values and turn them into strings.
%   1) Use 'precision' to make the seconds value have a leading zero when necessary and
%       have a uniform number of zeros after the decimal.
%   2) Horizontally concatenate everything.
%   3) Turn the character array into a cell array.
tic
delimeter = ':';
format_spec = ['%0' num2str(precision+3) '.' num2str(precision), 'f'];
second = cellstr(num2str(SS, format_spec));

delim = repmat(delimeter, records, 1);
t_hms = cellstr([num2str(HH, '%02d'), delim, ...
                 num2str(MM, '%02d'), delim, ...
                 SS]);
speed = toc;
str = sprintf('  5     %6i %9.5f      %s', records, speed, strTimes{1}{1});
disp(str);
               
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% METHOD 6 \\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Maintain precision of all values -- do not append extra zeros
%   1) Turn the seconds into left-justified strings and trim all trailing spaces.
%   2) Use 'cellfun' to trim off the '0.' and only keep the fractional seconds.
%   3) Horizontally concatenate HH MM SS and turn into a cell array
%   4) Concatenate the decimal seconds onto that.
tic
delim = repmat(delimeter, records, 1);
decimal = strtrim(cellstr(strjust(num2str(mod(SS(:), 1)), 'left')));
decimal = cellfun(@(x) x(3:end), decimal, 'UniformOutput', false);
second = floor(SS);

t_hms = strcat(cellstr([num2str(HH, '%02i'), delim, ...
                        num2str(MM, '%02i'), delim, ...
                        second, repmat('.', records, 1)]), ...
               decimal);
speed = toc;
str = sprintf('  6     %6i %9.5f      %s', records, speed, strTimes{1}{1});
disp(str);
                 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% METHOD 7 \\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the second values that are less than 10 and append a 0 to them.
%   1) Search for seconds < 10 and append a 0
%   2) horizontaly concatenate HH MM SS sss, turn into a cell array, delete all white space
tic
ltTen = find(SS < 10);
second = strjust(num2str(SS), 'left');
append_zero = repmat('0', length(ltTen), 1);
second(ltTen(:,1),:) = [append_zero, second(ltTen)];

t_hms = strtrim(cellstr([num2str(HH, '%02i'), delim, ...
                         num2str(MM, '%02i'), delim, ...
                         second]));
speed = toc;
str = sprintf('  7     %6i %9.5f      %s', records, speed, strTimes{1}{1});
disp(str);
