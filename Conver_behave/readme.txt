1. (if need to get data) run ..\Generate\Script_plot_system.m
	before run: change number of active UEs ({n})
                        noUsers = {n};
	after run : change location and name of .mat file: 
			from "..\Generate\pos_BS_UEs.mat" 
			  to "..\Conver_behave\position_data\pos_BS_UEs_{n}UE.mat"
			   
2. run Script_compare.m
	before run: change number of UEs:
            NoUsers = 6;
	after run : change name .mat file:
			from "conver.mat" to "conver_{n}UE_4anten.mat"
					  or "conver_{n}UE_1anten.mat"
3.(if need to plot figure) run Script_plot_fig.m
	before run: load .mat file if needed