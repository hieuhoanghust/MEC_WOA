% NoUsers = 4:6:28; 
% NoUsers = 4:24:112; 
xt = {'4', '10', '16', '22', '28'}; 
% xt = {'4', '28', '52', '76', '100'}; 

% Create figure
h2 = figure('OuterPosition',[61 318 835 482]);

% Create axes
axes1 = axes('Position',...
    [0.137823198749905 0.161282164014256 0.839047615692728 0.79898771403988]);
hold(axes1,'on');
hold on
plot(NoUsers, po_WOA_BWOA(1:length(po_WOA_BWOA)), 'LineStyle', '-', 'linewidth', 2.0, 'Marker', 'o', 'MarkerSize', 13.0, 'Color', [0.00,0.00,1.00]);
plot(NoUsers, po_IWOA_BWOA(1:length(po_IWOA_BWOA)), 'LineStyle', '-', 'linewidth', 2.0, 'Marker', '*', 'MarkerSize', 13.0, 'Color', [0.9290 0.6940 0.1250]);
plot(NoUsers, po_PSO_BWOA(1:length(po_PSO_BWOA)), 'LineStyle', '-', 'linewidth', 2.0, 'Marker', '^', 'MarkerSize', 13.0, 'Color', [0.4940 0.1840 0.5560]);

plot(NoUsers, po_ARJOA(1:length(po_ARJOA)), 'LineStyle', '-', 'linewidth', 2.0 , 'Marker', 'diamond', 'MarkerSize', 13.0, 'Color', [0.00,1.00,0.00]);
plot(NoUsers, po_IOJOA(1:length(po_IOJOA)), 'LineStyle', '-', 'linewidth', 2.0, 'Marker', 'square', 'MarkerSize', 13.0, 'Color', [0.85,0.33,0.10]);
plot(NoUsers, po_OFDMA(1:length(po_OFDMA)), 'LineStyle', '-', 'linewidth', 2.0, 'Marker', 'v', 'MarkerSize', 13.0, 'Color', [0.75,0.00,0.75]);
plot(NoUsers, po_ALCA(1:length(po_ALCA)), 'LineStyle', '-', 'linewidth', 2.0, 'Marker', '>', 'MarkerSize', 13.0, 'Color', [0.00,0.00,0.00]);

grid on
set(gca, 'XLim', [NoUsers(1) NoUsers(length(NoUsers))], 'YLim', [0 1]);
xticks = NoUsers;
set(gca, 'xtick', xticks);
set(gca, 'xticklabel',xt);
set(gca, 'YTick', 0:0.2:1);
% set(gca, 'Yticklabel', {'0', '0.2', '0.4', '0.6', '0.8', '1.0'});
xlabel('Density of active UEs (\times 10^{-6}UEs/m^2)','FontSize',15);
ylabel('Offloading Percentage','FontSize',15);
lgnd = legend({'WOA BWOA', 'IWOA BWOA', 'PSO BWOA', 'ARJOA', 'IOJOA', 'OFDMA', 'ALCA'},...
    'Location', 'Best', 'FontSize',11, ...
    'Position',[0.148214283636639,0.662797618366424,0.265357147012438,0.24285714830671]);
%temp = [lgnd; lgnd.ItemText];
% set(temp, 'FontSize', 17.5); 
box(axes1,'on');
grid(axes1,'on');
hold(axes1,'off');
set(axes1,'FontSize',17.5,'PlotBoxAspectRatio',[5 2 1]);
% trick: save plot with minimal white space in matlab 
% ax = gca;
% outerpos = ax.OuterPosition;
% ti = ax.TightInset; 
% left = outerpos(1) + ti(1);
% bottom = outerpos(2) + ti(2);
% ax_width = outerpos(3) - ti(1) - ti(3);
% ax_height = outerpos(4) - ti(2) - ti(4);
% ax.Position = [left bottom ax_width ax_height];
hold

%savefig(h2, 'b1000_po'); 


% Create figure
h3 = figure('OuterPosition',[61 318 835 482]);

% Create axes
axes2 = axes('Position',...
    [0.137823198749905 0.161282164014256 0.839047615692728 0.79898771403988]);
hold(axes2,'on');
hold on
plot(NoUsers, su_WOA_BWOA(1:length(po_WOA_BWOA)), 'LineStyle', '-', 'linewidth', 2.0, 'Marker', 'o', 'MarkerSize', 13.0, 'Color', [0.00,0.00,1.00]);
plot(NoUsers, su_IWOA_BWOA(1:length(su_IWOA_BWOA)), 'LineStyle', '-', 'linewidth', 2.0, 'Marker', '*', 'MarkerSize', 13.0, 'Color', [0.9290 0.6940 0.1250]);
plot(NoUsers, su_PSO_BWOA(1:length(su_PSO_BWOA)), 'LineStyle', '-', 'linewidth', 2.0, 'Marker', '^', 'MarkerSize', 13.0, 'Color', [0.4940 0.1840 0.5560]);

plot(NoUsers, su_ARJOA(1:length(po_ARJOA)), 'LineStyle', '-', 'linewidth', 2.0 , 'Marker', 'diamond', 'MarkerSize', 13.0, 'Color', [0.00,1.00,0.00]);
plot(NoUsers, su_IOJOA(1:length(po_IOJOA)), 'LineStyle', '-', 'linewidth', 2.0, 'Marker', 'square', 'MarkerSize', 13.0, 'Color', [0.85,0.33,0.10]);
plot(NoUsers, su_OFDMA(1:length(po_OFDMA)), 'LineStyle', '-', 'linewidth', 2.0, 'Marker', 'v', 'MarkerSize', 13.0, 'Color', [0.75,0.00,0.75]);
plot(NoUsers, su_ALCA(1:length(po_ALCA)), 'LineStyle', '-', 'linewidth', 2.0, 'Marker', '>', 'MarkerSize', 13.0, 'Color', [0.00,0.00,0.00]);

grid on
set(gca, 'XLim', [NoUsers(1) NoUsers(length(NoUsers))], 'YLim', [0 ceil(max([max(su_WOA_BWOA) max(su_IWOA_BWOA) max(su_PSO_BWOA)]))]);
xticks = NoUsers;
set(gca, 'xtick', xticks);
set(gca, 'xticklabel',xt);
xlabel('Density of active UEs (\times 10^{-6}UEs/m^2)','FontSize',15);
ylabel('System Utility','FontSize',15);
set(gca, 'YTick', 0:2:110);
% set(gca, 'Yticklabel', {'0', '2', '4', '6', '8', '10'});
lgnd = legend({'WOA BWOA', 'IWOA BWOA', 'PSO BWOA','ARJOA', 'IOJOA', 'OFDMA', 'ALCA'}, 'Location', 'Best','FontSize',11,...
    'Position',[0.148214283636639,0.662797618366424,0.265357147012438,0.24285714830671]);
% temp = [lgnd; lgnd.ItemText];
% set(temp, 'FontSize', 17.5); 
hold
box(axes2,'on');
grid(axes2,'on');
hold(axes2,'off');
set(axes2,'FontSize',17.5,'PlotBoxAspectRatio',[5 2 1]);
