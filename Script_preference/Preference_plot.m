load('results\preference.mat')
% Create figure
figure('OuterPosition',[61 318 835 482]);
Beta_t = 0.1:0.2:0.9;

% Create axes
axes1 = axes('Position',...
    [0.137823198749905 0.161282164014256 0.839047615692728 0.79898771403988]);
hold(axes1,'on');

plot(Beta_t,ti_MEC_, '-o', 'LineWidth', 2.0, 'MarkerSize', 12, 'Color', [0.00,0.00,1.00] )
grid on
xlabel('\beta^t')
ylabel('Total execution time (s)')
yyaxis right
plot(Beta_t,en_MEC_, '-*', 'LineWidth',2.0, 'MarkerSize', 12, 'Color', [0.00,1.00,0.00] )
ylabel('Total execution energy (J)')
legend("time", "energy")

box(axes1,'on');
grid(axes1,'on');
hold(axes1,'off');
set(axes1,'FontSize',17.5,'PlotBoxAspectRatio',[5 2 1]);