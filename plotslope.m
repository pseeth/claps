load('slopes/checkslopes.mat');
smooth_db_data = 10*log10(smooth(abs((clap.^2)), floor(fs/10)));
figure(1);
%main portion
hold off;
plot((floor(fs/100):length(x)+floor(fs/100))./fs,smooth_db_data(floor(fs/100):length(x)+floor(fs/100)),'k','LineWidth',2);
hold on;
%direct sound
plot((1:floor(fs/100))./fs,smooth_db_data(1:floor(fs/100)),'--k','LineWidth',2);
%fit line
plot((x+floor(fs/100))./fs,polyval(lf,x),'-.r','LineWidth',2)
%background
plot((length(x)+floor(fs/100):length(x)+fs/2)./fs,smooth_db_data(length(x)+floor(fs/100):length(x)+fs/2),':k','LineWidth',2);
xlabel('Time (s)')
ylabel('Energy (dB)')
title('Example fit line for a clap')
legend('Linear decay region', 'Direct sound', 'Fit line','Background');
xlim([0 (length(x)+fs/2)/fs]);
text((floor(fs/200)+441)/fs, smooth_db_data(floor(fs/200)), '\leftarrow Direct sound','FontSize',16);
text((length(x) + floor(fs/100))/fs, smooth_db_data(length(x) + floor(fs/100))+.8, '\downarrow Knee point','FontSize',16);

saveas(1, ['slopes', '/', 'fitclap.eps']);
saveas(1, ['slopes', '/', 'fitclap.png']);