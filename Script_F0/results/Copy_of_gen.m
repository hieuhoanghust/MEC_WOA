noRealizations = 200;
NoUsers = 4:6:28;
su_PSO_BWOA = []';
su_IWOA_BWOA = []';
su_WOA_BWOA = []';
su_OFDMA = []';
su_IOJOA = []';
su_ARJOA = []';
su_ALCA = [0,0,0,0,0]';

save('Script_N.mat',"noRealizations" ,'NoUsers', ...
    'su_ALCA', 'su_WOA_BWOA', 'su_OFDMA', 'su_IWOA_BWOA');
