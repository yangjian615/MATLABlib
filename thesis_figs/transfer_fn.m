% Inputs
sc           = 1;
data_product = 'Hbr';
transfer_dir = '/Users/argall/Documents/Work/Programs/Magnetic Merging/Data/Transfer_Functions/';

% Read the transfer function
[cal_data, cal_freqs] = MrC_SCM_TransferFn(num2str(sc), transfer_dir, data_product);

% Plot

% Amplitude
subplot(2, 1, 1)
plot(cal_freqs, abs(cal_data));
title('Amplitude Correction Factor');
xlabel('Frequency (Hz)');
ylabel('Amplitude (nT)');

% Create a Legend
legend('X', 'Y', 'Z');


% Phase
%   angle = atan(real / imag)
subplot(2, 1, 2)
plot(cal_freqs, radtodeg(angle(cal_data)));
title('Phase Correction Factor');
xlabel('Frequency (Hz)');
ylabel('Angle (Degrees)');
ylim([-180, 180]);
set(gca,'YTick', [-180, -135, -90, -45, 0, 45, 90, 135, 180]);


% Save the figure
outdir  = '/Users/argall/Google Drive/Work/Thesis/argall_PhD_Thesis/Chapters/Chapter_5_MergeTech/Chp5_Figures/';
outfile = fullfile(outdir, 'transfer_fn');
print(gcf, '-depsc2', [outfile '.eps']);
print(gcf, '-dps',    [outfile '.ps']);
print(gcf, '-dpng',   [outfile '.png']);