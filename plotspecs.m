[mc,fs] = wavread('pcm6.wav');
 c = prepare(mc,fs);
 a = 50*floor(fs/100);
 
for i = 1:length(c),
 spectrogram(mc(c(i)-a:c(i)-2500),[],[],[],fs);
xlim([3990 4010])
colorbar
pause
end