%----------------------------------------------------------------------------------------
%%% Initialze positions of whales (SBSs' transmiting power in the case of P --> posi_p )
%----------------------------------------------------------------------------------------

% Output:
% posi_p = N_dl x M_dl x noSA  matrix	== positions of whales in 2-D searching for the best transmission powers

function [posi_a, posi_p] = Initialization_dl(functionname, noUsers, noSBS, UE_BS, P_SBS_min, P_SBS_max, noSearchAgents)
	% functionname 	== 'string'
	% noUsers == N_dl   	== number of DL UEs
	% noBSs   == M_dl    		   == number of BS (M+1 indicates BS_0 == MBS)
	% UE_BS   == N_dl x M_dl matrix  == binary matrix of relation of DL UEs and DL SBSs
    % P_SBS_max = 1 x M_dl matrix == transmit power budget of SBSs
    % P_SBS_min = double or 1 x M_dl
                        
 	posi_p = zeros(noUsers, noSBS, noSearchAgents);	% N_dl x M_dl x noSA matrix
    
    p_min = P_SBS_min.* UE_BS;    % N_dl x M_dl == lower bound of power transmission of M SBSs to N UEs
	p_max = P_SBS_max.* UE_BS;    % N_dl x M_dl == upper bound

	switch functionname
		%%
		case 'SIC_MEC'
			% setup posi_p
            for nSA = 1:noSearchAgents
			    posi_p(:,:,nSA) = UE_BS .* (1/noUsers *rand(size(posi_p(:,:,nSA))).*(p_max-p_min)+p_min);
            end
            SBS_busy = sum(UE_BS,1)>0; % SBSs that contain active UEs

			% setup posi_a
            k = 0;
 		    for i = 1:noSearchAgents
 				for m = 1:noSBS
 					if (SBS_busy(1,m))
 				        posi_a(m,k+1,i) = 1; 
                        k = rem(k+1, noSubcs);
 					end
 				end
            end 
end


		