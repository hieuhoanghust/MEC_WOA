N = 2:7;
ti_ex = [13.709546 93.443767 135.710764 1124.107079 1661.604009 6562.983165];
su_ex = [1.2619 2.1598 2.5220 3.4811 3.6086 4.2544];

ti_bwoa = [0.217650 0.510098 0.300166 3.901047 15.200082 34.474296];
su_bwoa = [1.2619 2.1495 2.5048 3.43589 3.6008645 4.15977];

figure
plot(N, ti_ex);
hold 
plot(N, ti_bwoa);
legend('Exhaustive Search', 'BWOA');

figure
plot(N, su_ex);
hold 
plot(N, su_bwoa);
legend('Exhaustive Search', 'BWOA');