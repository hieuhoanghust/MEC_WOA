
% % Create figure
% figure('OuterPosition',[61 318 835 482]);
% 
% % Create axes
% axes1 = axes('Position',...
%     [0.137823198749905 0.161282164014256 0.839047615692728 0.79898771403988]);
% hold(axes1,'on');

plot(1:length(conver_curve_iwoa), conver_curve_iwoa, 'LineWidth', 1.5)
hold on
plot(1:length(conver_curve_iwoa), conver_curve_woa, 'LineWidth', 1.5)
hold on
plot(1:length(conver_curve_iwoa), conver_curve_pso, 'LineWidth', 1.5)
legend("IWOA BWOA", "WOA BWOA", "PSO BWOA")
xlabel("Iteration")
ylabel("System utility (\times 10^8)")

box(axes1,'on');
grid(axes1,'on');
hold(axes1,'off');
% Set the remaining axes properties
% set(axes1,'FontSize',17.5,'PlotBoxAspectRatio',[5 2 1],'XTick',...
%     [0 50 100 150 200 250 300],'XTickLabel',{'0','50','100','150','200', '250', '300'}, ...
%     'YTick', [440000000 500000000 550000000 600000000 640000000] ,    'YTickLabel',{'4.4','5','5.5','6','6.4'});

% set(axes1,'FontSize',17.5,'PlotBoxAspectRatio',[5 2 1]);
% 
% % Create legend
% legend1 = legend(axes1,'show');
% set(legend1,...
%     'Position',[0.162099898967459 0.603122379390209 0.139194136901653 0.298200505711426],...
%     'FontSize',13);

% figure
% semilogy(1:length(conver_curve_iwoa), conver_curve_iwoa)
% hold on
% semilogy(1:length(conver_curve_iwoa), conver_curve_woa)
% hold on
% semilogy(1:length(conver_curve_iwoa), conver_curve_pso)
% legend("IWOA BWOA", "WOA BWOA", "PSO BWOA")