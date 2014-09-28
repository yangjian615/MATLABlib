filename = '/Users/argall/Google Drive/Work/Matt-Kristoff/test_polarization-2.txt';
assert(exist(filename, 'file') == 2, 'File does not exist.');

fileID = fopen(filename);

% Read the entire line of the header
for i = 1:2;
    header = fgets(fileID);
end

% Read the rest of the data
[data, count] = fscanf(fileID, '%g %g %g %g', [4 inf]);

% Close the file
fclose(fileID);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a spectrogram    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
nfft = 10*64*4;
noverlap = nfft/2;
window = nfft;
fs = 64.0;
[Sx,Fx,Tx,Px] = spectrogram(data(2,:), window, noverlap, nfft, fs);
[Sy,Fy,Ty,Py] = spectrogram(data(3,:), window, noverlap, nfft, fs);
[Sz,FZ,Tz,Pz] = spectrogram(data(4,:), window, noverlap, nfft, fs);

% Compute the angle between X and Y
phase_diff = (angle(Sy) - angle(Sx)) * 180.0/pi;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bx Single Period               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figBx = subplot(6,1,1);
plot(data(1,:), data(2,:));
title('Test Signal: Bx, Single Period')
xlabel('Time (s)')
xlim([0 10])
ylabel('Amplitude')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bx Power Spectral Density      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figx = subplot(6,1,2);

% Plot the spectrogram Px
surf(Tx, Fx, log10(Px), 'edgecolor', 'none');
view(0,90);
title('Test Signal: Bx');
xlabel('Time (Seconds)');
ylim([0 3.5]);
ylabel('Hz');

% Create a colorbar
cbx = colorbar('location', 'EastOutside');
set(get(cbx, 'YLabel'), 'String', {'Power' 'log(nT^2 * Hz)'});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% By Single Period               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figBx = subplot(6,1,3);
plot(data(1,:), data(3,:));
title('Test Signal: Bx, Single Period')
xlabel('Time (s)')
xlim([0 10])
ylabel('Amplitude')
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% By Power Spectral Density      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figy = subplot(6,1,4);

% Plot the spectrogram Px
surf(Ty, Fy, log10(Py), 'edgecolor', 'none');
view(0,90);
title('Test Signal: By');
xlabel('Time (Seconds)');
ylabel('Hz');
ylim([0 3.5]);

% Create a colorbar
cbx = colorbar('location', 'EastOutside');
set(get(cbx, 'YLabel'), 'String', {'Power' 'log(nT^2 * Hz)'});
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Phase Difference               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figy = subplot(6,1,5);

% Plot the spectrogram Px
surf(Tx, Fx, phase_diff, 'edgecolor', 'none');
view(0,90);
title('Test Signal: Phase Difference');
xlabel('Time (Seconds)');
ylabel('Hz');
ylim([0 3.5]);

% Create a colorbar
cbx = colorbar('location', 'EastOutside');
ylabel('Phase Diff');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Phase Difference Line Plot     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figy = subplot(6,1,6);

[~,ifreq] = min(abs(Fx-1.6));
plot(Tx, phase_diff(ifreq,:))
title('Test Signal: Phase Difference (f=1.6Hz)');
xlabel('Time (Seconds)');
ylabel('Phase Diff');
ylim([-180 180]);