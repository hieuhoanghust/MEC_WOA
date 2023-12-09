%load('conver_{n}UE_4anten.mat')
plot(1:(size(cv_bwoa_mean,2)), cv_bwoa_mean(1, 1:size(cv_bwoa_mean,2)), 'b-.', 'linewidth', 2.0, 'markers', 13.0); hold on
plot(1:(size(cv_bwoa_mean,2)), leader_score_bwoa_ex.*ones(1, size(cv_bwoa_mean,2)), 'Color', [1.00,0.41,0.16], 'LineStyle', '-.', 'linewidth', 2.0, 'markers', 13.0);
grid on
xlabel('Realizations')
ylabel('System Utility')
legend('Using BWOA', 'Using Exhaustive Search');