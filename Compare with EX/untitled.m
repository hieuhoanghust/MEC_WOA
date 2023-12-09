figure;
plot(NoUsers, ex_time, 'ro:','linewidth', 2.0, 'markers', 13.0);
hold on;
plot(NoUsers, bwoa_time, 'b*-','linewidth', 2.0, 'markers', 13.0);
legend({'Proposed Algorithm', 'Exhaustive Search'}, 'FontSize', 17.5);
box on
grid on
xlabel('Density of UEs (\times 10^{-4} UEs/m^2)');
ylabel('Algorithm Runtime (s)');


% xt = {'1','2','3','4', '5', '6'};
% ax = axes();
% set(ax, 'xticklabel',xt);