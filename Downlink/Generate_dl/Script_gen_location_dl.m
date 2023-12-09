% script to run gen_location_dl funtion

save_new_pos = 0; % =1 to save new positions and new figure
noUsers = 6;    % == N == number of offloaded UEs 
noSBS   = 4;     % == M
flag_plot = 1;   % =1 to plot figure

[UE_BS, UEs, BS] = gen_location_dl(noUsers, noSBS, flag_plot);

if save_new_pos = 1
    save("pos_BS_UEs_dl.mat","BS", "UE_BS", "UEs")
end