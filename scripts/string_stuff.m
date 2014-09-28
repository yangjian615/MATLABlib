clc            % clear the command window
clf            % clear the plot window; don't use this unless you have plots -,--,:,-.
clear all      % clear all variables
format long g  % +, bank, hex, long, rat, short, short g, short eng
format compact

Seconds = [ 0.1, 12.532, 4.53; 0.2, 13.532, 5.53 ]

% I need to convert to a string. The numbers have vary in precision (which should be preserved),
% if the number is < 10, I need to append a '0' to the front of it, and there should be no blank spaces.
% The result  for 'second' should be

% 1. I was confused by "preserve precision"...to me, 4.53 is not the same as 4.530, but at the end of your email
% you say "Just now I thought about appending 0's to the end of each number"

% t_final = {'00.1', '12.532', '04.53'}

strNum2str = num2str (Seconds, ' %06.3f ')

strSprintf = sprintf ('%06.3f ', Seconds)

strSeconds (:,:) = sprintf ('%06.3f ', Seconds)
size (strSeconds)

clear strSeconds
[ rows cols ] = size (Seconds)
strSeconds = sprintf ('%06.3f ', Seconds)

irows = 1:rows
icols = 1:cols
x1           = sprintf ('%06.3f ', Seconds (1,icols))
size (x1)
x2           = sprintf ('%06.3f ', Seconds (1:irows,:))
size (x2)
for i = 1:rows
  s = sprintf ('%06.3f ', Seconds (i,:))
  x3 (i,:) = s; % prealloc matrix for better speed
end
size (x3)
x3

% sprintf prints matrix elements in col order, and we want row order, so transpose
% note the difference twixt these last two examples! Look the same in command window, but not!
% fine for a file write (fprintf) but not to work with
x4 = sprintf ('%06.3f %06.3f %06.3f\n', Seconds');
size (x4)
x4