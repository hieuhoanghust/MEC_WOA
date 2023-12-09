load('compare_with_ex.mat')
xticks = 1:6;
xt = {'1','2','3','4', '5', '6'};

h2 = figure(2);
hold on
plot(NoUsers, bwoa_lead, 'b-', 'linewidth', 2.0, 'markers', 13.0);
plot(NoUsers, ex_lead, 'ro:', 'linewidth', 2.0, 'markers', 13.0);
grid on
set(gca, 'FontSize', 17.5, 'XLim', [1 6]);
set(gca, 'xtick', xticks);
set(gca, 'xticklabel', xt);
xlabel('Density of UEs (\times 10^{-4} UEs/m^2)');
ylabel('System Utility');
legend({'Proposed Algorithm', 'Exhaustive Search'}, 'Location', 'Best', 'FontSize', 17.5);
box on
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
hold
x = [0.3 0.5]; y = [0.6 0.5];
dim = [0.2 0.2 0.1 0.1];
annotation('ellipse',dim)
a = annotation('textarrow',x,y,'String','Optimality gap = 0.53%', 'FontSize', 24);
%savefig(h2, 'compare_with_ex_su');

% 
h3 = figure(3);
ax(1) = axes();
l1=line('parent',ax(1),'xdata',NoUsers,'ydata',bwoa_time, 'LineWidth', 2.0, 'MarkerSize', 13.0, 'Color', 'b');
set(ax(1), 'XLim', [1 6], 'FontSize', 17.5);
set(ax(1), 'xtick', xticks);
set(ax(1), 'xticklabel',xt);
xlabel('parent', ax(1), 'Density of Users (\times 10^{-4} UEs/m^2)');
ylabel('parent', ax(1), 'Algorithm Runtime (s)');
grid on
box on

ax = ax(1);
outerpos = ax.OuterPosition;
ti = ax.TightInset;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

ax(2) = axes('position', [0.18 0.57 0.25 0.4]);
l2=line('parent',ax(2),'xdata',NoUsers,'ydata',ex_time,'LineWidth', 2.0, 'Marker', 'o', 'MarkerSize', 13.0, 'Color', 'r', 'LineStyle', ':');
set(ax(2), 'XLim', [1 6], 'xticklabel', [], 'FontSize', 17.5, 'YTick', [100,4000,8000,12000]);
axis tight
box on
grid on

lngd = legend( [l1;l2] , {'Proposed Algorithm','Exhaustive Search'}, 'FontSize', 17.5);
% savefig(h3, 'ex_time');