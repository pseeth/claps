function [f, fr, v, clap, fen, n, rv, brms, info] = analyze(sounds)

    [mc, fs] = wavread(sounds);
    c = prepare(mc,fs);
    mc = mc(:,1);
    f={};
    fr={};
    v={};
    clap = {};
    fen = {};
    n = {};
    rv = {};
    brms = {};
    info = {};
    ds_e = {};
    b = {};
    basev = {};
    base = {};
    hold off;
    results = '';
    
    for i=1:length(c),
        i
        a = 50*floor(fs/100);
        if i == length(c),
            [fr{i}, f{i}, clap{i}, fen{i}, n{i}, brms{i}, rv{i}, v{i}, info{i}, ds_e{i}, b{i},basev{i},base{i}] = main(mc(c(i)-a:end), fs);
        else
            [fr{i}, f{i}, clap{i}, fen{i}, n{i}, brms{i}, rv{i}, v{i}, info{i}, ds_e{i}, b{i},basev{i},base{i}] = main(mc(c(i)-a:c(i+1)-a), fs);
        end
        results = [results, sprintf('\nCLAP %d\n', i), inf];
        info{i} = inf;
    end
     
    sfen = std(cell2mat(fen),0,2);
    afen = mean(cell2mat(fen),2);
    
    
    p = 1;
    while (sounds(p) ~= '.'),
        p = p + 1;
    end
    
    foldername = sounds(1:p-1);
    mkdir(foldername);
    filename = fopen([foldername, '/', foldername, '.txt'],'wt');
    clapstats = 'OVERALL STATISTICS';
    reverbstats = sprintf('\nReverberation\n\tMean: %d, Standard deviation: %d\n\n', mean(cell2mat(rv)),std(cell2mat(rv)));
    volumestats = sprintf('\nVolume\n\tMean: %d, Standard deviation: %d\n\n', mean(cell2mat(v)),std(cell2mat(v)));
    noiselevel = sprintf('\nNoise level\n\tBase energy\n\tMean: %d, Standard deviation: %d\n\tVariance\n\tMean: %d, Standard deviation: %d\n\n', mean(cell2mat(brms)),std(cell2mat(brms)),  mean(cell2mat(n)),std(cell2mat(n))); 
    fenstats = sprintf('\nFrequency energy (Standard deviation, followed by average on each line)\n\t63   Hz:\t%d s\t%d s\n\t125  Hz:\t%d s\t%d s\n\t250  Hz:\t%d s\t%d s\n\t500  Hz:\t%d s\t%d s\n\t1000 Hz:\t%d s\t%d s\n\t2000 Hz:\t%d s\t%d s\n\t4000 Hz:\t%d s\t%d s\n\t8000 Hz:\t%d s\t%d s\n', sfen(1), afen(1), sfen(2),afen(2), sfen(3),afen(3), sfen(4),afen(4), sfen(5),afen(5), sfen(6),afen(6), sfen(7),afen(7), sfen(8),afen(8));
    next = sprintf('\n\nINDIVIDUAL CLAP ANALYSIS');
    
    clapstats = strcat(clapstats, reverbstats, volumestats, noiselevel, fenstats, next, results);
    
    fprintf(filename, '%s', clapstats);
    fclose(filename);

% save data
save([foldername, '/variables.mat'], 'fr', 'f', 'clap', 'fen', 'n', 'brms', ...
     'rv', 'v', 'info', 'ds_e', 'b','basev');

% plot data
%plot_old(foldername) % the old plots script
plot_it(foldername)

end

function [s,f] = pspec(data,fs,freq_vec)
% power spectrum, in standard units, not decibels
% only first parameter, the samples, are required
% returns spectrum and frequency vectors
    freq_vec = 125*sqrt(2).^[-4:14]; %20*(1.415.^(1:20));
    wsize=floor(fs/1000);
    [s,f]=pwelch(data,rectwin(wsize),[],freq_vec,fs);
    s=s.*f; % conver from specral density to spectrum
end
