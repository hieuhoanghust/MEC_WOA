% ----------------
% script: change task input (the data size)
% ----------------
tic
clear all
addpath('..\WOA_voronoi\')
addpath('..\Generate\')
addpath('..\')
load('..\Parameters\parameters2.mat')

% noSearchAgents = 30; 
users_no = 10;
M_ul = 3; 
M_dl = 3;
noBSs   = M_ul + M_dl;
noSubcs = 5;
noAnten = 4;

noRealizations = 3; %200
params.noRealizations = noRealizations;

C_n_sample = 0.5:0.5:2.5; %1:1:5; % x1e9
params.D_n = 0.42*1e6;
doTol = 1; 

ALCA.po = zeros(length(C_n_sample), 1); 
su_ALCA = zeros(length(C_n_sample), noRealizations); 

ARJOA.po = ones(length(C_n_sample), 1); 
su_ARJOA = zeros(length(C_n_sample), noRealizations); 

WOA_BWOA.po = zeros(length(C_n_sample), 1); 
su_WOA_BWOA = zeros(length(C_n_sample), noRealizations); 

IOJOA.po = zeros(length(C_n_sample), 1); 
su_IOJOA = zeros(length(C_n_sample), noRealizations); 

OFDMA.po = zeros(length(C_n_sample), 1);
su_OFDMA = zeros(length(C_n_sample), noRealizations);

PSO_BWOA.po = zeros(length(C_n_sample), 1);
su_PSO_BWOA = zeros(length(C_n_sample), noRealizations);

IWOA_BWOA.po = zeros(length(C_n_sample), 1);
su_IWOA_BWOA = zeros(length(C_n_sample), noRealizations);  

for iN = 1:length(C_n_sample)
	C_n = C_n_sample(iN); 
    params.C_n = 1e9*C_n; 
    po_WOA_BWOA_iN  = [];
    po_ARJOA_iN     = [];
    po_OFDMA_iN     = [];
    po_IOJOA_iN     = [];
    po_IWOA_BWOA_iN = [];
    po_PSO_BWOA_iN  = [];
   
	for iReal = 1:noRealizations
		fprintf('iN:%i/%i   iReal:%i/%i\n', iN, length(C_n_sample), iReal, noRealizations);
        
        UEs.total = [4 6 10];
        while UEs.total(1) ~= UEs.total(2) % force N_ul = N_dl trick to get average quicker
            [UE_BS, UEs, BS] = location_voronoi(users_no, M_ul, M_dl, 0);
            % UE_BS_   == N_active x M matrix % matrix of relation of UEs and SBSs
            % UEs == 1x1 struct
            %       UEs.active   == N_active_ue x 2 matrix == (N_ul + N_dl) x 2 matrix
            %       UEs.inactive == N_inactive x 2 matrix
            %       UEs.inBS     == 1 x N_active_ue  : SBS that covers the active UEs
            %       UEs.total    == 1 x 2 matrix == [N_ul N_dl N]
            %       UEs.d        == N_active x N_active : distances between active UEs
            % BS  == 1x1 struct
            %       BS.positions == N_sbs x 2 matrix
            %       BS.SBS       == N_sbs x 1 cell : save the positions of UEs that the SBS covers
            %       BS.total = [M_ul M_dl M]
            %       BS.d     == M x M == distances between SBSs and DL SBSs
        end
        N_ul = UEs.total(1);

        [ChannelGain, ~] = channelMod(UEs, BS, noAnten, noSubcs, logNormalMean, logNormalDeviation);
        % ChannelGain == struct with
        %       hArray 	  == N x M x K cell,
        %                  each cell is a L x 1 vector  == vector of channel gain
        %                   (each SBS has L antennas)
        %       h2h       == N x N x M x K matrix
        %                   ex: h2h(1,1,m,k) = ||h_{1m}^k||^2
        %                       h2h(1,2,m,k) = |h_{1m}^k'*h_{2m}^k|
        %       h_UE      == N_ul x N_dl x K matrix
        %       G_SBS     == M_ul x M_dl x K cell
        %                       each cell == L (ul) x L (dl) matrix
        % ~     	  == N x M matrix 	== distance from UEs to SBSs

        t = randi(800, 1);
        var.f_l = params.f_user(t: t+N_ul-1);
        T_l = params.C_n ./ var.f_l;
        E_l = params.kappa .* params.C_n .*(var.f_l) .^2;

        var.eta     = params.beta_t .* params.D_n ./ (T_l);
        var.theta   = params.beta_e .* params.D_n ./ (params.zeta .* E_l);

        var.Adet = 1;
	
        %%%%%%%%%%%%%%%%%%%%%
        %       ALCA
        %%%%%%%%%%%%%%%%%%%%%
        fprintf('ALCA\n')
        po_ALCA(iN, iReal) = 0;
        [var.lb_woa, var.ub_woa, var.P_SBS_min, var.P_SBS_max, fobj_woa, fobj_woa_dl, fobj_bwoa] = getFunctionDetails2('ALCA', UEs, BS, UE_BS, noSubcs, ChannelGain, params, var);
        % function in ..\
        % only perform BWOA for DL
        [ALCA_BWOA_result, ~, ~] = BWOA2('ALCA', doTol, UEs, BS, UE_BS, fobj_bwoa, fobj_woa, fobj_woa_dl, ChannelGain.h2h, params, var);
%                 [ALCA_BWOA_result, ~, ~] = int_WOA('ALCA', doTol, UEs, BS, UE_BS, fobj_bwoa, fobj_woa, fobj_woa_dl, ChannelGain.h2h, params, var);
        %    function in ..\WOA_voronoi
        su_ALCA(iN, iReal) = ALCA_BWOA_result.leader_score;    

        %%%%%%%%%%%%%%%%%%%%%
        %       ARJOA
        %%%%%%%%%%%%%%%%%%%%%
        fprintf('ARJOA\n')
        [var.lb_woa, var.ub_woa, var.P_SBS_min, var.P_SBS_max, fobj_woa, fobj_woa_dl, fobj_bwoa] = getFunctionDetails2('ARJOA', UEs, BS, UE_BS, noSubcs, ChannelGain, params, var);
        % function in ..\

        [ARJOA_BWOA_result, ARJOA_WOA_result, ~] = BWOA2('ARJOA', doTol, UEs, BS, UE_BS, fobj_bwoa, fobj_woa, fobj_woa_dl, ChannelGain.h2h, params, var);
        %         [ARJOA_BWOA_result, ARJOA_WOA_result, ~] = int_WOA('ARJOA', doTol, UEs, BS, UE_BS, fobj_bwoa, fobj_woa, fobj_woa_dl, ChannelGain.h2h, params, var);
        %    function in ..\WOA_voronoi


        % offloading vector
        % leader_score_bwoa = ARJOA_BWOA_result.leader_score;
        leader_pos_bwoa_ul = ARJOA_BWOA_result.leader_pos(1:N_ul, :);

        if N_ul > 0
            temp = sum(sum(leader_pos_bwoa_ul))/N_ul;
            po_ARJOA_iN = [po_ARJOA_iN temp];
        end
        su_ARJOA(iN, iReal) = ARJOA_BWOA_result.leader_score;
          
        %%%%%%%%%%%%%%%%%%%%%
        %      MF SIC
        %%%%%%%%%%%%%%%%%%%%%
        fprintf('WOA BWOA\n')
        [var.lb_woa, var.ub_woa, var.P_SBS_min, var.P_SBS_max, fobj_woa, fobj_woa_dl, fobj_bwoa] = getFunctionDetails2('SIC_MEC', UEs, BS, UE_BS, noSubcs, ChannelGain, params, var);
        %   function in ..\

        [BWOA_result, WOA_result, time] = BWOA2('WOA_SIC_MEC', doTol, UEs, BS, UE_BS, fobj_bwoa, fobj_woa, fobj_woa_dl, ChannelGain.h2h, params, var);
        %         [BWOA_result, WOA_result, time] = int_WOA('WOA_SIC_MEC', doTol, UEs, BS, UE_BS, fobj_bwoa, fobj_woa, fobj_woa_dl, ChannelGain.h2h, params, var);
        %    function in ..\WOA_voronoi

        leader_pos_bwoa_ul   = BWOA_result.leader_pos(1:N_ul, :);
        if N_ul > 0
            temp = sum(sum(leader_pos_bwoa_ul))/N_ul;
            po_WOA_BWOA_iN = [po_WOA_BWOA_iN temp];
        end
        % po_WOA_BWOA_iN == 1 x?? vector (?? \leq noReal)
        %                == offloading percentage (not consider circumstances with no UL UE)
        su_WOA_BWOA(iN, iReal) = BWOA_result.leader_score;

        %   IWOA BWOA
        fprintf('IWOA BWOA\n')
        [IWOA_BWOA_result, IWOA_result, ~] = BWOA2('IWOA_SIC_MEC', doTol, UEs, BS, UE_BS, fobj_bwoa, fobj_woa, fobj_woa_dl, ChannelGain.h2h, params, var);
%         [IWOA_BWOA_result, IWOA_result, ~] = int_WOA('IWOA_SIC_MEC', doTol, UEs, BS, UE_BS, fobj_bwoa, fobj_woa, fobj_woa_dl, ChannelGain.h2h, params, var);
        %    function in ..\WOA_voronoi

        if N_ul > 0
            temp = sum(sum(IWOA_BWOA_result.leader_pos(1:N_ul, :)))/N_ul;
            po_IWOA_BWOA_iN = [po_IWOA_BWOA_iN temp];
        end
        % po_IWOA_BWOA_iN == 1 x?? vector (?? \leq noReal)
        %                 == offloading percentage (not consider circumstances with no UL UE)
        su_IWOA_BWOA(iN, iReal) = IWOA_BWOA_result.leader_score;

        %   PSO BWOA
        fprintf('PSO BWOA\n')
        [PSO_BWOA_result, PSO_result, ~] = BWOA2('PSO_SIC_MEC', doTol, UEs, BS, UE_BS, fobj_bwoa, fobj_woa, fobj_woa_dl, ChannelGain.h2h, params, var);
%         [PSO_BWOA_result, PSO_result, ~] = int_WOA('PSO_SIC_MEC', doTol, UEs, BS, UE_BS, fobj_bwoa, fobj_woa, fobj_woa_dl, ChannelGain.h2h, params, var);
        %    function in ..\WOA_voronoi

        if N_ul > 0
            temp = sum(sum(PSO_BWOA_result.leader_pos(1:N_ul, :)))/N_ul;
            po_PSO_BWOA_iN = [po_PSO_BWOA_iN temp];
        end
        % po_PSO_BWOA_iN == 1 x?? vector (?? \leq noReal)
        %                == offloading percentage (not consider circumstances with no UL UE)
        su_PSO_BWOA(iN, iReal) = PSO_BWOA_result.leader_score;
         

        %%%%%%%%%%%%%%%%%%%%%
        %      IOJOA
        %%%%%%%%%%%%%%%%%%%%%
        fprintf('IOJOA\n')
        Adetermined = zeros(UEs.total(1), 1); % N_ul x 1
        % all users independently make offloading decision
        for i = 1:UEs.total(1)
            if rand() > 0.5
                continue
            end
            Adetermined(i) = 1;
        end
        var.Adet = Adetermined;

        [var.lb_woa, var.ub_woa, var.P_SBS_min, var.P_SBS_max, fobj_woa, fobj_woa_dl, fobj_bwoa] = getFunctionDetails2('IOJOA', UEs, BS, UE_BS, noSubcs, ChannelGain, params, var);
        % function in ..\

        [IOJOA_BWOA_result, IOJOA_WOA_result, ~] = BWOA2('IOJOA', doTol, UEs, BS, UE_BS, fobj_bwoa, fobj_woa, fobj_woa_dl, ChannelGain.h2h, params, var);
%                 [IOJOA_BWOA_result, IOJOA_WOA_result, ~] = int_WOA('IOJOA', doTol, UEs, BS, UE_BS, fobj_bwoa, fobj_woa, fobj_woa_dl, ChannelGain.h2h, params, var);
        % function in ..\WOA_voronoi

        if N_ul > 0
            temp = sum(sum(IOJOA_BWOA_result.leader_pos(1:N_ul, :)))/N_ul;
            po_IOJOA_iN = [po_IOJOA_iN temp];
        end
        % po_PSO_BWOA_iN == 1 x?? vector (?? \leq noReal)
        %                == offloading percentage (not consider circumstances with no UL UE)
        su_IOJOA(iN, iReal) = IOJOA_BWOA_result.leader_score;

        
        %%%%%%%%%%%%%%%%%%%%%
        %      OFDMA
        %%%%%%%%%%%%%%%%%%%%%
        fprintf('OFDMA\n')

        [var.lb_woa, var.ub_woa, var.P_SBS_min, var.P_SBS_max, fobj_woa, fobj_woa_dl, fobj_bwoa] = getFunctionDetails2('OFDMA', UEs, BS, UE_BS, noSubcs, ChannelGain, params, var);
        %             function in ..\

        [OFDMA_BWOA_result, OFDMA_WOA_result, ~] = BWOA2('OFDMA', doTol, UEs, BS, UE_BS, fobj_bwoa, fobj_woa, fobj_woa_dl, ChannelGain.h2h, params, var);
%                 [OFDMA_BWOA_result, OFDMA_WOA_result, ~] = int_WOA('OFDMA', doTol, UEs, BS, UE_BS, fobj_bwoa, fobj_woa, fobj_woa_dl, ChannelGain.h2h, params, var);
        % function in ..\WOA_voronoi

        if N_ul > 0
            temp = sum(sum(OFDMA_BWOA_result.leader_pos(1:N_ul, :)))/N_ul;
            po_OFDMA_iN = [po_OFDMA_iN temp];
        end
        % po_PSO_BWOA_iN == 1 x?? vector (?? \leq noReal)
        %                == offloading percentage (not consider circumstances with no UL UE)
        su_OFDMA(iN, iReal) = OFDMA_BWOA_result.leader_score;
    end 
    WOA_BWOA.po(iN,1) = mean(po_WOA_BWOA_iN); 
    IWOA_BWOA.po(iN,1) = mean(po_IWOA_BWOA_iN); 
    PSO_BWOA.po(iN,1) = mean(po_PSO_BWOA_iN);
    
    IOJOA.po(iN,1) = mean(po_IOJOA_iN);

    OFDMA.po(iN,1) = mean(po_OFDMA_iN);
end 

ALCA.su = mean(su_ALCA, 2);

WOA_BWOA.su = mean(su_WOA_BWOA, 2);
IWOA_BWOA.su = mean(su_IWOA_BWOA, 2);
PSO_BWOA.su = mean(su_PSO_BWOA, 2);

ARJOA.su = mean(su_ARJOA, 2);

IOJOA.su = mean(su_IOJOA, 2);

OFDMA.su = mean(su_OFDMA, 2);

save('results\new\Script_Cn_1.mat', 'C_n_sample', 'users_no', ...
     'ALCA','WOA_BWOA', "IWOA_BWOA", "PSO_BWOA", "ARJOA", "IOJOA", "OFDMA");

toc 