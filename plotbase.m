b_mat = cell2mat(b');
    b_mat = max( zeros(size(b_mat)), b_mat );

    boxplot(10*log10(b_mat), 'labelorientation','inline','labels',round(125*sqrt(2).^[-4:14]));
    title('Baseline spectra');
    xlabel('Frequency (Hz)');
    ylabel('Normalized energy (dB)');
    saveas(1, 'pcm5/Baseline-newvec-Box.eps');
    saveas(1, 'pcm5/Baseline-newvec-Box.png');