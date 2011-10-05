function [fr,f,clap,fen,n,brms,rv,volume,info,ds_e,b_e,basev,base] = main(data, fs, ds)
    warning off;
    [base,clap, max_index] = baseline(data,fs);
    [i, env] = decayfind(base,clap);
    volume = env(1,2);
    basev  = 20*log10(rms(base));
    [rv, s] = rt(clap,fs,i);
    
    info = sprintf('---------------------------------------------------');
    info = [info, sprintf('\nClap volume: %d db\n', env(1,2))];
    info = [info, sprintf('\nExtrapolated RT60: %d seconds\n', rv)];
    
    cutoff = floor(length(base)/10);
    
    %base = base(cutoff:end-cutoff);
    [n, brms] = noisefloor(base,fs);
    info = [info, sprintf('\nNoise floor\nVariance = %d, Energy = %d\n',n,brms)];

%     figure(1);
%     w = size(base);
%     padding = zeros(w(1),1);    
%     hold off;
%     subplot(2,1,1);
%     plot(cat(1,base,clap));
%     hold on;
%     plot(cat(1,padding,clap(1:i)),'r'), title('reverberation time for a clap');
%     plot(cat(1,padding,env(:,1)),'k','LineWidth',1);
%     legend('entire waveform', 'the clap', 'average energy for the clap');
%     
%     subplot(2,1,2);
%     plot(env(:,2));
    
    fen = frt(clap,fs,i);
   
    info = [info, sprintf('\nReverb times for frequencies\n')];
    info = [info, sprintf('63   Hz:\t%d s\n125  Hz:\t%d s\n250  Hz:\t%d s\n500  Hz:\t%d s\n1000 Hz:\t%d s\n2000 Hz:\t%d s\n4000 Hz:\t%d s\n8000 Hz:\t%d s\n', fen(3), fen(5), fen(7), fen(9), fen(11), fen(13), fen(15), fen(17))];
    
    
    %clap = data(max_index-25*floor(fs/1000):max_index+s);
    
    if nargin > 2
        [fr, f, ds_e, b_e] = freqrespo(base(1:end-cutoff), clap, fs, ds);
    else
        [fr, f, ds_e, b_e] = freqrespo(base(1:end-cutoff), clap, fs);
    end
    
    info = [info, sprintf('---------------------------------------------------\n')];
end

function freq_rt = frt(clap, fs, guess)
% computes the reverb time in each of a set of octave-spaced frequencies
    wsize = floor(fs/100);
    f = [125*sqrt(2).^[-4:14]]';
    [stft,f,T,spec_clap] = spectrogram(clap,floor(fs/100),0,f,fs);
    spec_clap = spec_clap .* repmat( f, 1, size(spec_clap,2) ); % convert to power spectrum
    spec_clap = 10*log10(spec_clap);
    thresh = 10;
    h = size(spec_clap);
    freq_rt = zeros(h(1),1);
    for i = 1:h(1),
        freq_rt(i) = srt(spec_clap(i,1:end), guess, wsize, thresh)*floor(fs/100)/fs;
    end
end

function f_rt = srt(spec_clap, guess, wsize, thresh)
    if (var(spec_clap) < thresh),
        f_rt = 0;
        return;
    end
    
    guess_end = floor(guess/wsize);
    smooth_db_data = smooth(spec_clap, 30);
    smooth_db_data = smooth_db_data(10:end);
    error = fit_error(smooth_db_data(:, 1), 1);
    trim = floor(guess_end/3); % ignore the first 1/3 of the clap
    knee = find_knee(error(trim:trim+guess_end)) + trim - 1;
    x = (1:knee)';
    linear_fit = polyfit(x,smooth_db_data(1:knee),1);
    initial = smooth_db_data(1);
    f_rt = (((initial-60-linear_fit(2))/linear_fit(1)));
end

function [reverb_time,s] = rt(clap,fs,guess)
% compute reverb time from a clap recording, using line fitting method.
    wsize = floor(fs/100);
    wsmooth = floor(fs/10);
    werror = floor(fs/100);
    wreverb = fs;
    guess_end = floor(guess/wsize);
    
    % computing the energy envelope, smoothing with 100ms window
    smooth_db_data = 10*log10(smooth(abs((clap.^2)), wsmooth));
    ds_end = floor(fs/100);
    % cut off the direct sound, which we assume to be in first 10ms
    smooth_db_data = smooth_db_data(ds_end:end);
    % compute error of linear fits for larger and larger windows starting
    % at the beginning and ending at time i*10ms, where i is index in 
    % error vector.
    error = fit_error(smooth_db_data(1:end), werror);
    % find "knee point" meaning that error suddendly becomes larger because
    % we have left the linear decay region of the recording.
    trim = floor(guess_end/10);
    last = trim + guess_end;
    if last > length(error),
        last = length(error);
    end
    knee = find_knee(error(trim:last)) + trim - 1;
    % x is the vector of indices of smooth_db_data for the linear decay region.
    x = (1:knee*wsize)';
    s=length(x);
    % calculate slope in the linear decay region
    linear_fit = polyfit(x,smooth_db_data(1:knee*wsize),1);
    initial = smooth_db_data(1);
    reverb_time = ((initial-60-linear_fit(2))/linear_fit(1))/wreverb;
end

function error = fit_error(smooth_db_data, wsize)
    error = zeros(floor(size(smooth_db_data)/wsize),1);
%     for i = 1:wsize:size(smooth_db_data),
%         x = (1:i)';
%         p = polyfit(x,smooth_db_data(1:i),1);
%         linear_fit = polyval(p,x);
%         current = floor(1+i/wsize);
%         error(current) = norm(smooth_db_data(1:i)-linear_fit,2);
%     end
%     error = error./(1:length(error))';
    for i = 1:length(error),
        x = (1:i*wsize)';
        p = polyfit(x,smooth_db_data(x),1);
        linear_fit = polyval(p,x);
        error(i) = norm(smooth_db_data(x)-linear_fit,2);
    end
    error = error./(1:length(error))';
end

function knee = find_knee(error)
    [~,i] = min(error);
    thresh = min(error)*1.1;
    while((error(i) < thresh) && (i < length(error))),
        i = i+1;
    end
    knee = i;
end

% function knee = find_knee(error)
%     longest = 0;
%     size_seq = 0;
%     knee = 0;
%     for i = 1:(size(error)-1),
%         if (error(i+1) >= error(i))
%            size_seq = size_seq+1;
%         end
%         if (error(i+1)-error(i) > .01*(sum(error)/length(error)) || i == length(error) - 1),
%             if (size_seq > longest),
%                 longest = size_seq;
%                 knee = i - size_seq + 1;
%             end
%             size_seq = 0;
%         end
%     end
% end

function [v, brms] = noisefloor(base,fs)
    wsize = floor(fs/100);
    base = base(wsize:(end-wsize));
    brms = rms(base);
    all = [];
    c = 1;
    for i = 1:floor(wsize/2):length(base)-wsize,
       current = rms(base(i:i+wsize));
       all(c) = current;
       c = c+1;
    end
    v = std(all);
%     freq_res=128;
%     s=10*log10(abs(spectrogram(base,hamming(wsize),[],freq_res,fs).^2));
%     v = sum(var(s,[],2))/size(s,1); % normalize by number of freq bins
end

function [i, env] = decayfind(base, clap)
    cutoff = floor(length(base)/10);
    b = 20*log10(rms(base(cutoff:end-cutoff)));
    i = 1;
    wsize = 441;
    error = .001;
    sclap = size(clap);
    env = zeros(sclap(1),2);
    env_count = 1;
    c = 20*log10(rms(clap(1:(wsize))));
    while ~((c - b) < error),
        c = 20*log10(rms(clap(i:(i+wsize))));
        i = i + wsize;
        env(env_count,1) = 10^(c/20);
        env(env_count,2) = c;
        env_count = env_count+wsize;
    end
    env = env(1:env_count-wsize,:);
end

function r = rms(window)
    r = sqrt(sum(window.^2)/length(window));
end

function [fr, f, ds_e, b_e] = freqrespo(base, clap, fs, ds)
    a = 50;
    if nargin < 4
        ds = clap(1:floor(a*fs/1000));
    end
    rs = clap(floor(a*fs/1000):end);
    
    [b_p,f] = pspec(base,fs);
    rs_p_raw = pspec(rs,fs);
    ds_p_raw = pspec(ds,fs);
    
    % compute power spectra
    rs_p = rs_p_raw - b_p;
    ds_p = ds_p_raw - b_p;

    % convert to energy by accounting for length
    rs_e = rs_p * (length(clap)/fs);
    ds_e = ds_p * (length(ds)/fs);
    b_e = b_p * (length(base)/fs);
 
    fr = rs_e./ds_e;
end

function [s,f] = pspec(data,fs,freq_vec)
% power spectrum, in standard units, not decibels
% only first parameter, the samples, are required
% returns spectrum and frequency vectors
    freq_vec = 125*sqrt(2).^[-4:14];%[63,125,250,500,1000,2000,4000,8000,16000]
    wsize=floor(fs/1000);
    [s,f]=pwelch(data,rectwin(wsize),[],freq_vec,fs);
    s=s.*f; % conver from specral density to spectrum
end

function [base, clap, max_index] = baseline(data,fs)
    [~, max_index] = max(data);
    wsize = 10;
    baseenergy = rms(data(1:max_index/2)); % use 0.25 s of data for baseline
    i = 1;
    
    while(rms(data(i:i+wsize)) < 10*baseenergy),
        i = i+1;
    end
    
    base = data(1:i);
    clap = data(i:end);
end
