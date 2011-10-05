function checkslopes(sounds)
    [mc, fs] = wavread(sounds);
    mc = mc(:,1);
    
    c = prepare(mc,fs);
    
    for i = 1:length(c)
        i
        a = 50*floor(fs/100);
        if i == length(c),
            last = length(mc);
        else
            last = c(i+1)-a;
        end
        [base,clap, max_index] = baseline(mc(c(i)-a:last),fs);
        [i, env] = decayfind(base,clap);
        [rv, s, lf, x] = rt_slope(clap,fs,i);
    end
    mkdir('slopes');
    save('slopes/checkslopes.mat');
end


function [reverb_time,s,linear_fit,x] = rt_slope(clap,fs,guess)
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

function r = rms(window)
    r = sqrt(sum(window.^2)/length(window));
end
