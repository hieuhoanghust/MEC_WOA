load('results\Script_compare.mat')
xticks = 2:7;
xt = {'2','3','4', '5', '6','7'};

h2 = figure(2);
hold on
plot(NoUsers, BWOA.su, 'b*-', 'linewidth', 2.0, 'markers', 13.0);
plot(NoUsers, EX.su, 'ro-.', 'linewidth', 2.0, 'markers', 13.0);
grid on
set(gca, 'FontSize', 17.5, 'XLim', [2 7]);
set(gca, 'xtick', xticks);
set(gca, 'xticklabel', xt);
xlabel('Density of UEs (\times 10^{-6} UEs/m^2)');
ylabel('System Utility');
legend({'BWOA', 'Exhaustive Search'}, 'Location', 'Best', 'FontSize', 17.5);
box on
% ax = gca;
% outerpos = ax.OuterPosition;
% ti = ax.TightInset;
% left = outerpos(1) + ti(1);
% bottom = outerpos(2) + ti(2);
% ax_width = outerpos(3) - ti(1) - ti(3);
% ax_height = outerpos(4) - ti(2) - ti(4);
% ax.Position = [left bottom ax_width ax_height];
hold
x = [0.3 0.5]; y = [0.6 0.5];
dim = [0.2 0.2 0.1 0.1];
annotation('ellipse',dim)
a = annotation('textarrow',x,y,'String','Optimality gap = 2.21%', 'FontSize', 24);
%savefig(h2, 'compare_with_ex_su');

% 
h3 = figure(3);
hold on
plot(NoUsers, BWOA.time, 'b*-', 'linewidth', 2.0, 'markers', 13.0);
plot(NoUsers, EX.time, 'ro-.', 'linewidth', 2.0, 'markers', 13.0);
grid on
set(gca, 'FontSize', 17.5, 'XLim', [2 7]);
set(gca, 'xtick', xticks);
set(gca, 'xticklabel', xt);
xlabel('Density of UEs (\times 10^{-6} UEs/m^2)');
ylabel('Algorithm Runtime (s)');
legend({'BWOA', 'Exhaustive Search'}, 'Location', 'Best', 'FontSize', 17.5);
box on

grid on
% savefig(h3, 'ex_time');