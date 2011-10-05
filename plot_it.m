function plot_it( foldername )

% load saved data
load([foldername '/variables.mat']);

set(0,'DefaultAxesFontName','Times');
set(0,'DefaultAxesFontSize',20);
    figure(1);
    semilogx(cell2mat(f')',10*log10(cell2mat(fr')'), '-x');
    xlim([200 20000]);
    title('Frequency responses');
    xlabel('Frequency (Hz)');
    ylabel('Energy (dB)');
    saveas(1,[foldername, '/', 'Frequency-Response.eps']);
    saveas(1,[foldername, '/', 'Frequency-Response.png']);

    figure(6);
% set freq_response to zero if negative
fr_mat = cell2mat(fr');
fr_mat = max( zeros(size(fr_mat)), fr_mat );

    boxplot(10*log10(fr_mat), 'labelorientation','inline',...
            'labels',round(f{1}),'whisker',100);
    title('Frequency responses');
    xlabel('Frequency (Hz)');
    ylabel('Energy (dB)');
    saveas(6, [foldername, '/', 'Frequency-Response-Box.eps']);
    saveas(6, [foldername, '/', 'Frequency-Response-Box.png']);

    figure(7);
% set freq_response to zero if negative
dse_mat = cell2mat(ds_e');
dse_mat = max( zeros(size(dse_mat)), dse_mat );

    boxplot(10*log10(dse_mat), 'labelorientation','inline',...
            'labels',round(f{1}),'whisker',100);
    title('Direct sound spectra');
    xlabel('Frequency (Hz)');
    ylabel('Normalized energy (dB)');
    saveas(7, [foldername, '/', 'Direct-Sound-Box.eps']);
    saveas(7, [foldername, '/', 'Direct-Sound-Box.png']);

if( 0 )
    figure(5);
    fr_mat = cell2mat(fr')';
    norm_energy = fr_mat(10,:); %median(fr_mat);
    semilogx(cell2mat(f')',10*log10(fr_mat./repmat(norm_energy,size(fr_mat,1),1)), '-x');
    xlim([200 20000]);
    title('Frequency responses');
    xlabel('Frequency (Hz)');
    ylabel('Normalized energy (dB)');
    saveas(1,[foldername, '/', 'Frequency-Response-Normalized.eps']);
    saveas(1,[foldername, '/', 'Frequency-Response-Normalized.png']);
end

    figure(2);
    semilogx(cell2mat(f'),std(10*log10(cell2mat(fr')'),0,2),'k-x');
    xlim([200 20000]);
    title('Standard deviation of frequency response');
    ylabel('Standard deviation (dB)');
    xlabel('Frequency (Hz)');
    saveas(2,[foldername, '/', 'Frequency-Response-Std-Dev.eps']);
    saveas(2,[foldername, '/', 'Frequency-Response-Std-Dev.png']);
    
    figure(4);
    semilogx( round(f{1}),cell2mat(fen),'x-')
    title('Reverberation times for frequency bins');
    xlabel('Frequency (Hz)');
    ylabel('Time (s)');
    axis([200 10000 0 10]);
    saveas(4, [foldername, '/', 'Reverb-Times-Freq.eps']);
    saveas(4, [foldername, '/', 'Reverb-Times-Freq.png']);

    figure(5);
    % don't plot bad low frequency results
    % blank them out
    fen_mat = cell2mat(fen)';
    for i=1:6
        fen_mat(:,i) = 0;
    end
    f_mat   = round(f{1}(1:end));
    boxplot(fen_mat, 'labelorientation','inline',...
            'labels',f_mat,'whisker',100);
    xlabel('Frequency (Hz)');
    ylabel('RT60 reverberation time (s)');
    ylim([0 5]);
    xlim([2.5 18.5]);
hold on
plot( [3, 5,    7,    9,    11,   13,   15,   17,],...
      [3, 2.77, 2.57, 2.48, 2.12, 1.63, 1.27, .83], 'x-' );
legend( 'balloon pop' );
hold off
    saveas(5, [foldername, '/', 'Reverb-Times-Freq-Box.eps']);
    saveas(5, [foldername, '/', 'Reverb-Times-Freq-Box.png']);
    
    b_mat = cell2mat(b');
    b_mat = max( zeros(size(b_mat)), b_mat );

    figure(8)
    boxplot(10*log10(b_mat), 'labelorientation','inline',...
            'labels',round(f{1}),'whisker',100);
    title('Background spectra');
    xlabel('Frequency (Hz)');
    ylabel('Normalized energy (dB)');
    saveas(8, [foldername, '/', 'Baseline-Box.eps']);
    saveas(8, [foldername, '/', 'Baseline-Box.png']);
        
