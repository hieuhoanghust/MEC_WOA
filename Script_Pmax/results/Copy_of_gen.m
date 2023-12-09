noRealizations = 200;
users_no = 10;
su_PSO_BWOA = []';
su_IWOA_BWOA = []';
su_WOA_BWOA = []';
su_OFDMA = []';
su_IOJOA = []';
su_ARJOA = []';
su_ALCA = [0,0,0,0,0]';

save('Script_F0.mat',"noRealizations", 'users_no' ,'F0', 'su_PSO_BWOA', ...
    "su_ARJOA" ,'su_IOJOA', 'su_ALCA', 'su_WOA_BWOA', 'su_OFDMA', 'su_IWOA_BWOA');
