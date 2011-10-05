[mc, fs] = wavread('pcm5.wav');
    c = prepare(mc,fs);
    mc = mc(:,1);
    base = {};
    
    for i=1:length(c),
        i
        a = 50*floor(fs/100);
        base{i} = mc(c(i)-a:c(i));
        sound(base{i},fs);
        pause;
    end