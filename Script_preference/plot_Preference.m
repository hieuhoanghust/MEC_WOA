% figure 
% plot3(Beta_t,Beta_t,ti_MECNOMA21_1, '--o')
% grid on
% xlabel('\beta^t')
% ylabel('\beta^e')
% zlabel('Total execution time (s)')
% 
% figure
% plot3(Beta_t,Beta_t,en_MECNOMA21_1, '--o')
% grid on
% xlabel('\beta^t')
% ylabel('\beta^e')
% zlabel('Total execution energy (J)')

% Create figure
figure('OuterPosition',[61 318 835 482]);
Beta_t = 0.1:0.2:0.9;

% Create axes
axes1 = axes('Position',...
    [0.137823198749905 0.161282164014256 0.839047615692728 0.79898771403988]);
hold(axes1,'on');

en_MEC_  = [10.7159515053406 11.4226930471175 12.6641901394440 15.7061001310923 17.6533199498882];
ti_MEC_  = [9.29176126942536 8.99981425795769 8.52936940580397 8.31145275090218 7.88263788596829];

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