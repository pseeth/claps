function claps = prepare(data,fs)
    wsize = floor(fs/100);
    claps = [];
    ci = 1;
    clapflag = 0;
    baseenergy = rms(data(1:wsize*10));
    i = 1;
    while (i < (length(data)-wsize)),
        current = rms(data(i:i+wsize-1));
        if (current > 10*baseenergy),
            if clapflag == 0,
                claps(ci) = i;
                ci = ci+1;
                clapflag = 1;
            end
        elseif (current < 2*baseenergy)
            if clapflag == 1,
                clapflag = 0;
            end
        end
        i = i + wsize;   
    end
end

function r = rms(window)
    w = size(window);
    r = sqrt(sum(window.^2)/(w(1)));
end