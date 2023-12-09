%-------------------
% script: change the number of users in the DL
%-------------------
tic
clear all
format long

addpath('Generate_dl\')
addpath('..\')
load('..\Parameters\parameters2.mat')
% load('..\Parameters\parameters2.mat')
% noSearchAgents = 30;
NoUsers = 10; %4:6:28 ;
noBSs   = 7;
noSubcs = 5;
noAnten = 4;
P_SBS_max = 39.81; % 46 dBm
P_SBS_min = 0.25*10^(-3);
gamma_th = 1.001;

noRealizations = 1; %200
maxIter = 800;

doTol = 0;

% po: offloading percentage
% su: system utiliy

xt = cell(1, length(NoUsers));
for iN = 1:length(NoUsers)
    users_no = NoUsers(iN);
    xt(iN) = {num2str(users_no)};
    channelGain = zeros(users_no, noBSs, noSubcs, noRealizations);
    
    R_nm   = zeros(users_no, noBSs, noRealizations);
    UE_BS_cell = cell(noRealizations, 1); % == noRealizations x 1 cell
                                          %    to save UE_BS of each realization

    for iReal = 1:noRealizations
        [UE_BS_, UEs, BS] = gen_location_dl(users_no, noBSs, 0);
        [~, hArray, dA]   = channelMod(UEs, BS, noAnten, noSubcs, logNormalMean, logNormalDeviation);
            % function in ..\
            % return hA   == N x M x K cell, 
            %               each cell is a L x 1 vector  == vector of channel gain
            %                (each SBS has L antennas)
            %        R_nm == N x M matrix 	== distance from UEs to BSs

        UE_BS_cell{iReal, 1} = UE_BS_;
        R_nm(:,:,iReal) = dA;
    end
    
    for iReal = 1:noRealizations
        fprintf('iN:%i/%i   iReal:%i/%i\n', NoUsers(iN), NoUsers(length(NoUsers)), iReal, noRealizations);
        t = randi(800, 1);
        
        UE_BS = UE_BS_cell{iReal,1};
        r_nm  = R_nm(:,:,iReal);   % N x M matrix
                
         
         %     %%%%%%%%%%%%%%%%%%%%%

           
         %%%%%%%%%%%%%%%%%%%%%
         %      MEC NOMA DL
         %%%%%%%%%%%%%%%%%%%%%
         fprintf('MEC NOMA DL\n')
         [fobj_woa, fobj_bwoa] = getFunctionDetails_dl('MEC_NOMA_DL', users_no, noSubcs, noBSs, UE_BS, hArray, ...
            P_SBS_max, gamma_th, n0, W, nu);

%          to compare WOA with Improved - WOA
%          [leader_score_bwoa, leader_pos_bwoa, ~, ~, ~, ~, ~] = BWOA2_matrix(...
%               'MEC_NOMA21', doTol, noSearchAgents, users_no, noSubcs, noBSs, UE_BS, maxIter, fobj_bwoa, lb_woa, ub_woa, fobj_woa,...
%                  theta, eta, W, h2h_, n0, p_min, p_max, nu, 0);
%             function in ..\WOA_voronoi

         % Compare with WOA_BWOA
%          [leader_score_WOAbwoa, leader_pos_WOAbwoa, ~, conver_curve_WOA_BWOA, ~, ~, timeWOA] = BWOA_dl(...
%               'MEC_NOMA_DL', noSearchAgents, users_no, noSubcs, noBSs, UE_BS, maxIter, fobj_bwoa, P_SBS_min, P_SBS_max, fobj_woa);

         [leader_score_PSObwoa, leader_pos_PSObwoa, ~, conver_curve_PSO_BWOA, ~, ~, timePSO] = PSO_BWOA_dl(...
              'MEC_NOMA_DL', noSearchAgents, users_no, noSubcs, noBSs, UE_BS, maxIter, fobj_bwoa, P_SBS_min, P_SBS_max, fobj_woa);
%             
         
%        leader_pos_bwoa == M x K matrix == Broadcasting matrix 
                  
         su_MECNOMA21(iN, iReal) = leader_score_bwoa;  

         
               
    end
end

toc

