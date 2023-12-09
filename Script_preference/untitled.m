fprintf("10 UEs \n")
run ScriptPreference10.m;
save('new\preference10.mat', 'Beta_t' ,'po_MEC', 'su_MEC', 'ti_MEC', 'en_MEC',...
    'po_MEC_mean', 'su_MEC_mean', 'ti_MEC_mean', 'en_MEC_mean','users_no');
fprintf("---------------------\n")

fprintf("16 UEs \n")
run ScriptPreference10.m;
save('new\preference16.mat', 'Beta_t' ,'po_MEC', 'su_MEC', 'ti_MEC', 'en_MEC',...
    'po_MEC_mean', 'su_MEC_mean', 'ti_MEC_mean', 'en_MEC_mean','users_no');
fprintf("---------------------\n")

fprintf("22 UEs \n")
run ScriptPreference10.m;
save('new\preference22.mat', 'Beta_t' ,'po_MEC', 'su_MEC', 'ti_MEC', 'en_MEC',...
    'po_MEC_mean', 'su_MEC_mean', 'ti_MEC_mean', 'en_MEC_mean','users_no');
fprintf("---------------------\n")
