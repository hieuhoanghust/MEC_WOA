%-------------------
% script: change the number of users
%-------------------
tic
clear all
addpath('..\WOA_voronoi\')
addpath('..\Generate\')
addpath('..\')
load('..\Parameters\parameters2.mat')
dbstop if error;
% noSearchAgents = 30;
NoUsers = 22:6:28;% 22:6:28; %4:6:28 ;
M_ul = 3; 
M_dl = 3;
noBSs   = M_ul + M_dl;
noSubcs = 5;
noAnten = 4;

params.noSubcs = noSubcs;
params.noAnten = noAnten;
params.noBSs   = noBSs;
params.maxIter = 800;

params.noRealizations = 10; %10; %200
noRealizations = params.noRealizations;

doTol = 1; % result tolerant: 1 for early break / 0 to run all iterations

% po: offloading percentage
% su: system utiliy

po_ALCA = zeros(length(NoUsers), noRealizations);
su_ALCA = zeros(length(NoUsers), noRealizations);

po_ARJOA = zeros(length(NoUsers), noRealizations);
su_ARJOA = zeros(length(NoUsers), noRealizations);

po_IWOA_BWOA = zeros(length(NoUsers), noRealizations);
su_IWOA_BWOA = zeros(length(NoUsers), noRealizations);
ti_IWOA_BWOA = zeros(length(NoUsers), noRealizations);

po_PSO_BWOA = zeros(length(NoUsers), noRealizations);
su_PSO_BWOA = zeros(length(NoUsers), noRealizations);
ti_PSO_BWOA = zeros(length(NoUsers), noRealizations);

po_WOA_BWOA = zeros(length(NoUsers), noRealizations);
su_WOA_BWOA = zeros(length(NoUsers), noRealizations);
ti_WOA_BWOA = zeros(length(NoUsers), noRealizations);
WOA_BWOA.po = zeros(length(NoUsers),1);

po_IOJOA = zeros(length(NoUsers), noRealizations);
su_IOJOA = zeros(length(NoUsers), noRealizations);

po_OFDMA = zeros(length(NoUsers), noRealizations);
su_OFDMA = zeros(length(NoUsers), noRealizations); 
xt = cell(1, length(NoUsers));

logNormalMean = params.logNormalMean;
logNormalDeviation = params.logNormalDeviation;

for iN = 1:length(NoUsers)
    users_no = NoUsers(iN);
    xt(iN) = {num2str(users_no)};
    po_WOA_BWOA_iN = [];

    for iReal = 1:noRealizations
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
        N_ul = UEs.total(1);

        [ChannelGain, ~] = channelMod(UEs, BS, noAnten, noSubcs, logNormalMean, logNormalDeviation);
        % ChannelGain == struct with 
            % hArray 	  == N x M x K cell, 
            %                  each cell is a L x 1 vector  == vector of channel gain
            %                   (each SBS has L antennas)
            % h2h         == N x N x M x K matrix
            %                   ex: h2h(1,1,m,k) = ||h_{1m}^k||^2
                                  % h2h(1,2,m,k) = |h_{1m}^k'*h_{2m}^k|
            % h_UE        == N_ul x N_dl x K matrix
            % G_SBS       == M_ul x M_dl x K cell
                             % each cell == L (ul) x L (dl) matrix
        % ~     	  == N x M matrix 	== distance from UEs to SBSs
        % H2H{iReal, 1} = h2h;
        % UE_BS_cell{iReal, 1} = UE_BS_;
    
        fprintf('iN:%i/%i   iReal:%i/%i\n', NoUsers(iN), NoUsers(length(NoUsers)), iReal, noRealizations);
        t = randi(800, 1);
        var.f_l = params.f_user(t: t+N_ul-1);
        T_l = params.C_n ./ var.f_l;
        E_l = params.kappa .* params.C_n .*(var.f_l) .^2;
     
        var.eta     = params.beta_t .* params.D_n ./ (T_l);
        var.theta   = params.beta_e .* params.D_n ./ (params.zeta .* E_l);

        %     %%%%%%%%%%%%%%%%%%%%%
        %     %       ALCA
        %     %%%%%%%%%%%%%%%%%%%%%
         fprintf('ALCA\n');
         po_ALCA(iN, iReal) = 0;
         su_ALCA(iN, iReal) = 0;
         
         
         
             %%%%%%%%%%%%%%%%%%%%%
             %       ARJOA
             %%%%%%%%%%%%%%%%%%%%%
%           fprintf('ARJOA\n')
%            [var.lb_woa, var.ub_woa, fobj_woa, fobj_woa_dl, fobj_bwoa] = getFunctionDetails2('ARJOA', UEs, BS, UE_BS, noSubcs, ChannelGain, params, var);
%                % function in ..\
%           
%            [BWOA_result, WOA_result, time] = BWOA2('ARJOA', doTol, UEs, BS, UE_BS, fobj_bwoa, fobj_woa, fobj_woa_dl, h2h, params, var); 
%           
%            % offloading vector
%            leader_score_bwoa = BWOA_result.leader_score;
%            leader_pos_bwoa = BWOA_result.leader_pos(1:N_ul, :);
%            A_ARJOA      = sum(leader_pos_bwoa, 2); % N_ul x 1 matrix
%            off_users_no = sum(A_ARJOA);
%           
%            po_ARJOA(iN, iReal) = off_users_no/N_ul;
%            su_ARJOA(iN, iReal) = leader_score_bwoa;
           
         %%%%%%%%%%%%%%%%%%%%%
         %      MF SIC
         %%%%%%%%%%%%%%%%%%%%%
         fprintf('MF SIC\n')
         [var.lb_woa, var.ub_woa, var.P_SBS_min, var.P_SBS_max, fobj_woa, fobj_woa_dl, fobj_bwoa] = getFunctionDetails2('SIC_MEC', UEs, BS, UE_BS, noSubcs, ChannelGain, params, var);       
            %   function in ..\

         [BWOA_result, WOA_result, time] = int_WOA('SIC_MEC', doTol, UEs, BS, UE_BS, fobj_bwoa, fobj_woa, fobj_woa_dl, ChannelGain.h2h, params, var); 
            %    function in ..\WOA_voronoi

         % subchannel association
         leader_pos_bwoa   = BWOA_result.leader_pos;

%          offloading vector
         leader_pos_bwoa_ul   = BWOA_result.leader_pos(1:N_ul, :);
         A_MECNOMA21 = sum(leader_pos_bwoa_ul, 2); % N_ul x 1 matrix
%          off_users_no = sum(A_MECNOMA21);
         
         if N_ul > 0 
            po_WOA_BWOA(iN, iReal) = sum(sum(leader_pos_bwoa_ul))/N_ul;
            po_WOA_BWOA_iN = [po_WOA_BWOA_iN po_WOA_BWOA(iN, iReal)];
         end
         su_WOA_BWOA(iN, iReal) = BWOA_result.leader_score;
% 
%         %          IWOA - BWOA
%          fprintf('IWOA BWOA\n')
%          [leader_score_IWOA_BWOA, leader_pos_IWOA_BWOA, leader_pos_IOWA, conver_curve_BWOA_iwoa, conver_curve_iwoa, ~, time_iwoa] = IWOA_BWOA(...
%               'MEC_NOMA21', doTol, noSearchAgents, users_no, noSubcs, noBSs, UE_BS, maxIter, fobj_bwoa, lb_woa, ub_woa, fobj_woa,...
%                  theta, eta, W, h2h_, n0, p_min, p_max, nu, 0);
% 
% %             function in ..\WOA_voronoi         
%          po_IWOA_BWOA(iN, iReal) = sum(sum(sum(leader_pos_IWOA_BWOA)))/users_no;
%          su_IWOA_BWOA(iN, iReal) = leader_score_IWOA_BWOA;
% %        
%         %          PSO BWOA
%          fprintf('PSO BWOA\n')
%          [leader_score_PSO_BWOA, leader_pos_PSO_BWOA, leader_pos_PSO, conver_curve_BWOA_pso, conver_curve_pso, ~, time_pso] = PSO_BWOA(...
%               'MEC_NOMA21', doTol, noSearchAgents, users_no, noSubcs, noBSs, UE_BS, maxIter, fobj_bwoa, lb_woa, ub_woa, fobj_woa,...
%                  theta, eta, W, h2h_, n0, p_min, p_max, nu, 0);
%          po_PSO_BWOA(iN, iReal) = sum(sum(sum(leader_pos_PSO_BWOA)))/users_no;
%          su_PSO_BWOA(iN, iReal) = leader_score_PSO_BWOA;


        %%%%%%%%%%%%%%%%%%%%%
        %      IOJOA
        %%%%%%%%%%%%%%%%%%%%%
        % fprintf('IOJOA\n')
        % Adetermined = zeros(users_no, 1);
        % % all users independently make offloading decision
        % for i = 1:users_no
        %     if rand() > 0.5
        %         continue
        %     end
        %     Adetermined(i) = 1;
        % end
        % 
        % [lb_woa, ub_woa, fobj_woa, fobj_bwoa] = getFunctionDetails2('IOJOA', users_no, noSubcs, noBSs, UE_BS, h2h_, ...
        %     p_min, p_max, P_tol, n0, W, eta, theta, nu, lambda, beta, f0, f_l, Adetermined);
        %     % function in ..\
        % 
        % [leader_score_bwoa, leader_pos_bwoa, ~, ~, ~, ~, ~] = BWOA2(...
        %       'IOJOA', doTol, noSearchAgents, users_no, noSubcs, noBSs, UE_BS, maxIter, fobj_bwoa, lb_woa, ub_woa, fobj_woa,...
        %          theta, eta, W, h2h_, n0, p_min, p_max, nu, Adetermined);
        %     % function in ..\WOA_voronoi
        % leader_score_bwoa
        % 
        % A_IOJOA      = sum(sum(leader_pos_bwoa, 2),3); % N x 1 matrix
        % off_users_no = sum(A_IOJOA);
        % 
        % po_IOJOA(iN, iReal) = off_users_no/users_no;
        % su_IOJOA(iN, iReal) = leader_score_bwoa;
        
        
        %%%%%%%%%%%%%%%%%%%%%
        %      OFDMA
        %%%%%%%%%%%%%%%%%%%%%
%         fprintf('OFDMA\n')
% 
%         [lb_woa, ub_woa, fobj_woa, fobj_bwoa] = getFunctionDetails2('OFDMA', users_no, noSubcs, noBSs, UE_BS, h2h_, ...
%             p_min, p_max, P_tol, n0, W, eta, theta, nu, lambda, beta, f0, f_l, 0);
% %             function in ..\
% 
%          [leader_score_bwoa, leader_pos_bwoa, ~, ~, ~, ~, ~] = BWOA2(...
%               'OFDMA', doTol, noSearchAgents, users_no, noSubcs, noBSs, UE_BS, maxIter, fobj_bwoa, lb_woa, ub_woa, fobj_woa,...
%                  theta, eta, W, h2h_, n0, p_min, p_max, nu, 0);
% %             function in ..\WOA_voronoi
%          leader_score_bwoa
%         
%         % offloading vector
%         A_OFDMA      = sum(sum(leader_pos_bwoa, 2),3); 
%         off_users_no = sum(A_OFDMA);
%         
%         po_OFDMA(iN, iReal) = off_users_no/users_no;
%         su_OFDMA(iN, iReal) = leader_score_bwoa;
               
    end
    % po_WOA_BWOA_iN == 1 x?? vector (?? <= noReal) 
    %                == offloading percentage (not consider circumstances with no UL UE)
    WOA_BWOA.po(iN,1) = mean(po_WOA_BWOA_iN); 
    WOA_BWOA.BWOA_result = BWOA_result;
    WOA_BWOA.WOA_result  = WOA_result;
end
% WOA_BWOA.po = mean(po_WOA_BWOA, 2); % length(NoUsers) x 1 
WOA_BWOA.su = mean(su_WOA_BWOA, 2);
WOA_BWOA.ti = mean(ti_WOA_BWOA, 2); 

% po_IWOA_BWOA = mean(po_IWOA_BWOA, 2);
% su_IWOA_BWOA = mean(su_IWOA_BWOA, 2);
% ti_IWOA_BWOA = mean(ti_IWOA_BWOA, 2);
% 
% po_PSO_BWOA = mean(po_PSO_BWOA, 2);
% su_PSO_BWOA = mean(su_PSO_BWOA, 2);
% ti_PSO_BWOA = mean(ti_PSO_BWOA, 2);

% % 
% po_ARJOA = mean(po_ARJOA, 2);
% su_ARJOA = mean(su_ARJOA, 2);
% 
% po_IOJOA = mean(po_IOJOA, 2);
% su_IOJOA = mean(su_IOJOA, 2);
% 
% po_OFDMA = mean(po_OFDMA, 2);
% su_OFDMA = mean(su_OFDMA, 2);
% 
% po_ALCA = mean(po_ALCA,2);
% su_ALCA = mean(su_ALCA,2);

% save('Script_N_compare_oldChan_WOA_IWOA_PSO_10_28_5Real.mat',"noRealizations" ,'NoUsers', 'po_WOA_BWOA', 'su_WOA_BWOA', 'ti_WOA_BWOA', 'po_IWOA_BWOA', 'su_IWOA_BWOA', 'ti_IWOA_BWOA',"ti_PSO_BWOA",...,
%         "ti_PSO_BWOA", 'su_PSO_BWOA', "po_PSO_BWOA", 'conver_curve_BWOA_woa', 'conver_curve_woa', 'time_woa',...
%         'leader_pos_IOWA', 'conver_curve_BWOA_iwoa', 'conver_curve_iwoa', 'time_iwoa',...
%         'leader_pos_PSO', 'conver_curve_BWOA_pso', 'conver_curve_pso', 'time_pso');

  save('scriptN_results\resp_result\Script_N_intWOA_22_28.mat', 'WOA_BWOA', 'NoUsers', 'noRealizations')


%NoUsers = 4:2:28; 
%xt = {'4', '8', '12', '16', '20', '24', '28'}; 

% h2 = figure(2)
% hold on
% plot(1:length(po_MECNOMA21), po_MECNOMA21(1:length(po_MECNOMA21)), 'b-o', 'linewidth', 2.0, 'markers', 13.0);
% plot(1:length(po_ARJOA), po_ARJOA(1:length(po_ARJOA)), 'g-v', 'linewidth', 2.0 , 'markers', 13.0);
% plot(1:length(po_IOJOA), po_IOJOA(1:length(po_IOJOA)), 'k-x', 'linewidth', 2.0, 'markers', 13.0);
% plot(1:length(po_OFDMA), po_OFDMA(1:length(po_OFDMA)), 'r-s', 'linewidth', 2.0, 'markers', 13.0);
% plot(1:length(po_ALCA), po_ALCA(1:length(po_ALCA)), 'k--d', 'linewidth', 2.0, 'markers', 13.0);
% grid on
% set(gca, 'FontSize', 17.5, 'XLim', [1 length(NoUsers)]);
% xticks = 1:length(NoUsers);
% set(gca, 'xtick', xticks);
% set(gca, 'xticklabel',xt)
% xlabel('Number of Users');
% ylabel('Offloading Percentage');
% lgnd = legend({'MEC NOMA21', 'ARJOA', 'IOJOA', 'OFDMA', 'ALCA'}, 'Location', 'Best')
% temp = [lgnd; lgnd.ItemText];
% set(temp, 'FontSize', 17.5); 
% box on
% % trick: save plot with minimal white space in matlab 
% ax = gca;
% outerpos = ax.OuterPosition;
% ti = ax.TightInset; 
% left = outerpos(1) + ti(1);
% bottom = outerpos(2) + ti(2);
% ax_width = outerpos(3) - ti(1) - ti(3);
% ax_height = outerpos(4) - ti(2) - ti(4);
% ax.Position = [left bottom ax_width ax_height];
% hold
% 
% savefig(h2, 'b1000_po'); 
% 
% 
% h3 = figure(3)
% hold on
% plot(1:length(su_MECNOMA21), su_ODSTCA(1:length(su_MECNOMA21)), 'b-o', 'linewidth', 2.0 , 'markers', 13.0);
% plot(1:length(su_ARJOA), su_ARJOA(1:length(su_ARJOA)), 'g-v', 'linewidth', 2.0, 'markers', 13.0);
% plot(1:length(su_IOJOA), su_IOJOA(1:length(su_IOJOA)), 'k-x', 'linewidth', 2.0, 'markers', 13.0);
% plot(1:length(su_OFDMA), su_OFDMA(1:length(su_OFDMA)), 'r-s', 'linewidth', 2.0, 'markers', 13.0);
% plot(1:length(su_ALCA), su_ALCA(1:length(su_ALCA)), 'k--d', 'linewidth', 2.0, 'markers', 13.0);
% grid on
% set(gca, 'FontSize',17.5,  'XLim', [1 length(NoUsers)], 'YLim', [-Inf Inf]);
% xticks = 1:length(NoUsers);
% set(gca, 'xtick', xticks);
% set(gca, 'xticklabel',xt);
% xlabel('Number of Users');
% ylabel('System Utility');
% lgnd = legend({'MEC NOMA21', 'ARJOA', 'IOJOA', 'OFDMA', 'ALCA'}, 'Location', 'Best')
% temp = [lgnd; lgnd.ItemText];
% set(temp, 'FontSize', 17.5); 
% hold
% box on 
% ax = gca;
% outerpos = ax.OuterPosition;
% ti = ax.TightInset; 
% left = outerpos(1) + ti(1);
% bottom = outerpos(2) + ti(2);
% ax_width = outerpos(3) - ti(1) - ti(3);
% ax_height = outerpos(4) - ti(2) - ti(4);
% ax.Position = [left bottom ax_width ax_height];
% savefig(h3, 'b1000_su')

toc

