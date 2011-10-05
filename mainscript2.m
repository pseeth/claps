[mc, fs] = wavread('pickmultipleclapstrim.wav');
c = prepare(mc,fs);
f={};
fr={};
v={};
clap = {};
fen = {};
n = {};
rv = {};
brms = {};
hold off;

for i=1:length(c),
    fprintf('\nCLAP %d\n', i);
    a = 50*floor(fs/100);
    if i == 19,
        [fr{i}, f{i}, clap{i}, fen{i}, n{i}, brms{i}, rv{i}, v{i}] = main(mc(c(i)-a:end), fs);
    else
        [fr{i}, f{i}, clap{i}, fen{i}, n{i}, brms{i}, rv{i}, v{i}] = main(mc(c(i)-a:c(i+1)-a), fs);
    end
end

figure;
for i=1:length(c);
   plot( f{i}, 10*log10(fr{i}))
   hold on 
end
