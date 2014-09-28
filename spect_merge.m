%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make a Spectrogram of the Data %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t_temp = t_merge(myObj.scm_intervals(3,1):myObj.scm_intervals(3,2));
b_temp = myObj.b_spun(myObj.scm_intervals(2,1):myObj.scm_intervals(2,2), :);

% Pick the number of points to average and initialize the averaged time and
% field arrays.
n_to_avg = 1;
t_avg = zeros(floor(length(t_temp)/n_to_avg), 1);
npts = length(t_avg);
b_avg = zeros(npts, 3);

% Define the start and stop indices for the averaging process
istart = 1;
iend = istart + n_to_avg - 1;
it_start = (iend - 1) / 2 + 1;

% Take the rolling average
if n_to_avg > 1
    for ii = 1:npts
        t_avg(ii) = t_temp(it_start);
        b_avg(ii,1) = mean(b_temp(istart:iend, 1));
        b_avg(ii,2) = mean(b_temp(istart:iend, 2));
        b_avg(ii,3) = mean(b_temp(istart:iend, 3));

        it_start = it_start + n_to_avg;
        istart = istart + n_to_avg;
        iend = iend + n_to_avg;
    end
else
    t_avg = t_temp;
    b_avg = b_temp;
end

nfft = 2^17;                            % number of points per FFT
n = floor(npts / nfft);                 % number of FFTs in the time interval
dt = (t_avg(end) - t_avg(1)) / npts;    % sample rate
df = 1 / (dt * nfft);                   % frequency bin size
fs = 1 / dt;                            % sample frequency
F = (0:nfft/2) * df;                    % FFT frequencies

n_desired = 250;
if n_desired < n
    n_desired = n;
end
noverlap = floor(nfft * (1 - n / n_desired));

start_timenum = t_avg(1) / 86400 + start_datenum;
f_max = 5;
if_max = find(F <= f_max, 1, 'last');

tic
[S,F,T,P] = spectrogram(b_avg(:,1), nfft, noverlap, F(1:if_max), fs);
toc

surface(T,F,10*log10(P), 'EdgeColor', 'none')
axis tight;
view(0,90);
xlabel(['Time (Seconds since ', datestr(start_timenum, 'HH:MM:SS.FFF'), ')']);
ylabel('Hz');
