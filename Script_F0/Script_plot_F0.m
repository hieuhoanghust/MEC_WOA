%F0  = 8:2:16; %8:2:16;
% xt = {'4', '10', '16', '22', '28'}; 
load("results\new\script_F0.mat")

% Create figure
h3 = figure('OuterPosition',[61 318 835 482]);

% Create axes
axes2 = axes('Position',...
    [0.137823198749905 0.161282164014256 0.839047615692728 0.79898771403988]);
hold(axes2,'on');

hold on
plot(F0, WOA_BWOA.su(1:length(WOA_BWOA.su)), 'LineStyle', '-', 'linewidth', 2.0, 'Marker', 'o', 'MarkerSize', 13.0, 'Color', [0.00,0.00,1.00]);
plot(F0, IWOA_BWOA.su(1:length(IWOA_BWOA.su)), 'LineStyle', '-', 'linewidth', 2.0, 'Marker', '*', 'MarkerSize', 13.0, 'Color', [0.9290 0.6940 0.1250]);
plot(F0, PSO_BWOA.su(1:length(PSO_BWOA.su)), 'LineStyle', '-', 'linewidth', 2.0, 'Marker', '^', 'MarkerSize', 13.0, 'Color', [0.4940 0.1840 0.5560]);

plot(F0, ARJOA.su(1:length(ARJOA.su)), 'LineStyle', '-', 'linewidth', 2.0 , 'Marker', 'diamond', 'MarkerSize', 13.0, 'Color', [0.00,1.00,0.00]);
plot(F0, IOJOA.su(1:length(IOJOA.su)), 'LineStyle', '-', 'linewidth', 2.0, 'Marker', 'square', 'MarkerSize', 13.0, 'Color', [0.85,0.33,0.10]);
plot(F0, OFDMA.su(1:length(OFDMA.su)), 'LineStyle', '-', 'linewidth', 2.0, 'Marker', 'v', 'MarkerSize', 13.0, 'Color', [0.75,0.00,0.75]);
plot(F0, ALCA.su(1:length(ALCA.su)), 'LineStyle', '-', 'linewidth', 2.0, 'Marker', '>', 'MarkerSize', 13.0, 'Color', [0.00,0.00,0.00]);

grid on

xlabel('Computing Resources of Servers (GHz)','FontSize',19.25);
ylabel('System Utility','FontSize',19.25);

lgnd = legend({'WOA BWOA', 'IWOA BWOA', 'PSO BWOA','ARJOA', 'IOJOA', 'OFDMA', 'ALCA'}, 'Location', 'Best','FontSize',13,...
    'Position',[0.161994818061105 0.590518316826363 0.139404298714362 0.292607809483882]);

hold
box(axes2,'on');
grid(axes2,'on');
hold(axes2,'off');
set(axes2,'FontSize',17.5,'PlotBoxAspectRatio',[5 2 1]);

