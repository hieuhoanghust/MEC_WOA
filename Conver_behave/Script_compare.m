%-----------------------------------
% check number of iterations until the algorithm is converged
%-----------------------------------
% First, run ..\Script\Script_plot_sytem.m 
% Then, save the figure and data into 'position_data' folder
addpath('..\WOA_voronoi\')
addpath('..\')
tic
clear all
load('..\Parameters\parameters2.mat')
%load('position_data\pos_BS_UEs_2UE.mat')

rng('default')

noSearchAgents = 30 ;
maxIter = 1000; %1000;
NoUsers = 6; % =6 
name = sprintf('position_data/pos_BS_UEs_%dUE.mat',NoUsers);
load(name);
noSubcs = 5; 
noBSs   = size(BS.positions, 1); % SBSs + 1MBS

% logNormalMean = 0;
% logNormalDeviation = 8.0;

noRealizations = 1; % 150 300; % 
noAnten = 4;

f0 = (1e9)*[8 8 8 8];

doTol = 0; % 

cv_bwoa = zeros(noRealizations, maxIter, length(NoUsers)); 
cv_woa  = zeros(noRealizations, maxIter, length(NoUsers)); 

cv_bwoa_mean = zeros(length(NoUsers), maxIter); 
cv_woa_mean  = zeros(length(NoUsers), maxIter); 

su_EX   = zeros(length(NoUsers), noRealizations); 

xt = cell(1, length(NoUsers));

noOff = zeros(size(NoUsers));

for iN = 1:length(NoUsers)
    
    users_no = NoUsers(iN);
    xt(iN) = {num2str(users_no)};
    H2H = cell(noRealizations,1); 
    % channelGain == noRealizations x 1 cell
    %                  each cell is a N x N x M x K matrix (h2h), 
    %                   ex: h2h(1,1,m,k) = ||h_{1m}^k||^2
    %                       h2h(1,2,m,k) = |h_{1m}^k'*h_{2m}^k| 
    R_nm   = zeros(users_no, noBSs, noRealizations);
    for iReal = 1:noRealizations
        [h2h, hA, dA] = channelMod(UEs, BS, noAnten, noSubcs, logNormalMean, logNormalDeviation);
            % function in ..\
            % return hA  == N x M x K cell, 
            %               each cell is a L x 1 vector  == vector of channel gain
            %                (each SBS has L antennas)
            %        h2h == N x N x M x K matrix
            %                   ex: h2h(1,1,m,k) = ||h_{1m}^k||^2
            %                       h2h(1,2,m,k) = |h_{1m}^k'*h_{2m}^k|
        H2H{iReal, 1} = h2h;
        R_nm(:,:,iReal) = dA;
    end

    for iReal = 1:noRealizations
        fprintf('process: iReal:%i/%i \t iN:%i/%i\n', iReal, noRealizations, iN, length(NoUsers))
        t = randi(800, 1);
        f_l = f_user(t:t+users_no-1);
        T_l = C_n./f_l;
        E_l = kappa.*C_n.*(f_l).^2;
                
        eta   = beta_t.*D_n./(T_l);          % N x 1 matrix
        theta = beta_e.*D_n./(zeta.*E_l);    % N x 1 matrix
        
        h2h_ = H2H{iReal, 1};
        %        h2h_ == N x N x M x K matrix
        %                   ex: h2h(1,1,m,k) = ||h_{1m}^k||^2
        %                       h2h(1,2,m,k) = |h_{1m}^k'*h_{2m}^k|
        r_nm   = R_nm(:,:,iReal); % N x M matrix
                
        %%%%%%%%%%%%%%%%%%%%%
        %      MEC-NOMA
        %%%%%%%%%%%%%%%%%%%%%
        
        Adetermined = 1; 
        [lb_woa, ub_woa, fobj_woa, fobj_bwoa] = getFunctionDetails2('MEC_NOMA21', users_no, noSubcs, noBSs, UE_BS, h2h_, ...
            p_min, p_max, P_tol, n0, W, eta, theta, nu, lambda, beta, f0, f_l, Adetermined);
            % function in ..\

        [leader_score_bwoa, leader_pos_bwoa, leader_pos_woa, conver_curve, conver_curve_woa, time_bwoa] = BWOA2(...
              'MEC_NOMA21', doTol, noSearchAgents, users_no, noSubcs, noBSs, UE_BS, maxIter, fobj_bwoa, lb_woa, ub_woa, fobj_woa,...
                 theta, eta, W, h2h_, n0, p_min, p_max, nu, Adetermined);
            % function in ..\WOA_voronoi
            
        [leader_score_bwoa_ex, leader_pos_bwoa_ex, leader_pos_woa_ex, time_ex] = exhaustive2(...
              'MEC_NOMA21', noSearchAgents, users_no, noSubcs, noBSs, UE_BS, maxIter, fobj_bwoa, lb_woa, ub_woa, fobj_woa,...
              theta, eta, W, h2h_, n0, p_min, p_max, nu);
            % function in ..\

%%%%%get parameters of offloading percentage
          nOff_iN   = sum(sum(sum(leader_pos_bwoa,3),2));
          noOff(iN) = noOff(iN) + nOff_iN;
%%%%%get parameters of conv curve%%%%
        cv_bwoa(iReal, :, iN) = conver_curve; 
        cv_woa(iReal, :, iN)  = conver_curve_woa; 
    end
    
    cv_bwoa_mean(iN, :) = mean(cv_bwoa(:, :, iN),1); 
    cv_woa_mean(iN, :) = mean(cv_woa(:, :, iN),1); 
end
 
save('conver.mat','NoUsers', 'cv_bwoa', 'cv_woa', 'cv_bwoa_mean', 'cv_woa_mean', 'leader_score_bwoa_ex', 'time_ex', 'time_bwoa')

toc
