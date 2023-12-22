load("results\new\Script_M.mat")


% Create figure
h3 = figure('OuterPosition',[61 318 835 482]);

% Create axes
axes2 = axes('Position',...
    [0.137823198749905 0.161282164014256 0.839047615692728 0.79898771403988]);
hold(axes2,'on');
hold on
plot(M_UL, WOA_BWOA.su(1:length(WOA_BWOA.su)), 'LineStyle', '-', 'linewidth', 2.0, 'Marker', 'o', 'MarkerSize', 13.0, 'Color', [0.00,0.00,1.00]);
plot(M_UL, IWOA_BWOA.su(1:length(IWOA_BWOA.su)), 'LineStyle', '-', 'linewidth', 2.0, 'Marker', '*', 'MarkerSize', 13.0, 'Color', [0.9290 0.6940 0.1250]);
plot(M_UL, PSO_BWOA.su(1:length(PSO_BWOA.su)), 'LineStyle', '-', 'linewidth', 2.0, 'Marker', '^', 'MarkerSize', 13.0, 'Color', [0.4940 0.1840 0.5560]);

plot(M_UL, ARJOA.su(1:length(ARJOA.su)), 'LineStyle', '-', 'linewidth', 2.0 , 'Marker', 'diamond', 'MarkerSize', 13.0, 'Color', [0.00,1.00,0.00]);
plot(M_UL, IOJOA.su(1:length(IOJOA.su)), 'LineStyle', '-', 'linewidth', 2.0, 'Marker', 'square', 'MarkerSize', 13.0, 'Color', [0.85,0.33,0.10]);
plot(M_UL, OFDMA.su(1:length(OFDMA.su)), 'LineStyle', '-', 'linewidth', 2.0, 'Marker', 'v', 'MarkerSize', 13.0, 'Color', [0.75,0.00,0.75]);
plot(M_UL, ALCA.su(1:length(ALCA.su)), 'LineStyle', '-', 'linewidth', 2.0, 'Marker', '>', 'MarkerSize', 13.0, 'Color', [0.00,0.00,0.00]);


grid on
% set(gca, 'XLim', [NoUsers(1) NoUsers(length(NoUsers))], 'YLim', [0 ceil(max([max(su_WOA_BWOA) max(su_IWOA_BWOA) max(su_PSO_BWOA)]))]);
xticks = M_UL;
xt = {'1', '2', '3', '4', '5'};
set(gca, 'xtick', xticks);
set(gca, 'xticklabel',xt);
xlabel('Density of UL SBSs (\times 10^{-6} SBSs/m^2)','FontSize',15);
ylabel('System Utility','FontSize',15);
% set(gca, 'YTick', 0:2:110);
% set(gca, 'Yticklabel', {'0', '2', '4', '6', '8', '10'});
% lgnd = legend({'WOA BWOA', 'IWOA BWOA', 'PSO BWOA','ARJOA', 'IOJOA', 'OFDMA', 'ALCA'}, 'Location', 'Best','FontSize',11,...
%     'Position',[0.148214283636639,0.662797618366424,0.265357147012438,0.24285714830671]);
lgnd = legend({'WOA BWOA', 'IWOA BWOA', 'PSO BWOA','ARJOA', 'IOJOA', 'OFDMA', 'ALCA'}, 'Location', 'Best','FontSize',11,...
    'Position',[0.148214283636639,0.662797618366424,0.265357147012438,0.24285714830671]);
% temp = [lgnd; lgnd.ItemText];
% set(temp, 'FontSize', 17.5); 
hold
box(axes2,'on');
grid(axes2,'on');
hold(axes2,'off');
set(axes2,'FontSize',17.5,'PlotBoxAspectRatio',[5 2 1]);
