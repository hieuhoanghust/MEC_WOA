%-----------------------------------
% change user's preference in time
%-----------------------------------
tic
clear all
addpath('..\WOA_voronoi\')
addpath('..\Generate\')
addpath('..\')
load('..\Parameters\parameters2.mat')

noRealizations = 20; % 200
M_ul = 3; 
M_dl = 3;
noBSs   = M_ul + M_dl;
Beta_t = 0.1:0.1:0.9; %0.1

users_no = 22;
noSubcs = 5;
params.noSubcs = noSubcs;
noAnten = 4;
params.noAnten = noAnten;


po_MEC = zeros(length(Beta_t), noRealizations);   % Offloading percentage 
su_MEC = zeros(length(Beta_t), noRealizations);   % System utility
ti_MEC = zeros(length(Beta_t), noRealizations);   % Time
en_MEC = zeros(length(Beta_t), noRealizations);   % Energy

xt_beta = cell(1, length(Beta_t));

for iK = 1:length(Beta_t)
    params.beta_t = Beta_t(iK);
    params.beta_e = 1 - beta_t;
    beta = [beta_t beta_e];
    xt_beta(iK) = {num2str(beta_t)};
    
    for iReal = 1:noRealizations
        fprintf('beta_t = %i/1   iReal = %i/%i\n', params.beta_t, iReal, noRealizations)
        
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
        var.f_l = params.f_user(t: t+N_ul-1); % N_ul x 1 _ local
        T_l = params.C_n ./ var.f_l;          % N_ul x 1 _ local
        E_l = params.kappa .* params.C_n .*(var.f_l) .^2; % N_ul x 1 _ local

        var.eta     = params.beta_t .* params.D_n ./ (T_l);
        var.theta   = params.beta_e .* params.D_n ./ (params.zeta .* E_l);

        var.Adet = 1;
        
        %%%%%%%%%%%%%%%%%%%%%
        %     MEC 
        %%%%%%%%%%%%%%%%%%%%%
        
        T_r_MEC = zeros(N_ul, 1);
        E_r_MEC = zeros(N_ul, 1);
        Rij_MEC = zeros(N_ul, 1);
        
        [var.lb_woa, var.ub_woa, var.P_SBS_min, var.P_SBS_max, fobj_woa, fobj_woa_dl, fobj_bwoa] = getFunctionDetails2('SIC_MEC', UEs, BS, UE_BS, noSubcs, ChannelGain, params, var);
        %   function in ..\

        [BWOA_result, WOA_result, time] = BWOA2('WOA_SIC_MEC', doTol, UEs, BS, UE_BS, fobj_bwoa, fobj_woa, fobj_woa_dl, ChannelGain.h2h, params, var);
        %    function in ..\WOA_voronoi
        
        leader_pos_bwoa_ul   = BWOA_result.leader_pos(1:N_ul, :); % N_ul x K
        leader_pos_woa = WOA_result.leader_pos_ul;
        cci_SBS = WOA_result.cci_SBS;
        
        % offloading vector
        A_MEC  = sum(leader_pos_bwoa_ul, 2); % N_ul x 1 matrix
        off_users_no = sum(A_MEC);               % number of offloading users 
        
        po_MEC(iK, iReal) = off_users_no/N_ul;
        off_idx = (A_MEC == 1); % N_ul x 1 binary logical
        loc_idx = (A_MEC == 0); % N_ul x 1

%         Z_l_MEC = loc_idx.*(beta_t.*T_l + beta_e.*E_l);
        
        tmp1 = sqrt(A_MEC.* params.beta_t.* var.f_l);  % N_ul x 1
        f_i = params.f0 .*(tmp1./sum(tmp1));        % N_ul x 1


        for i = 1:N_ul
            if A_MEC(i) == 0
                continue;
            end
            % j: offloading subcs
            temp1 = leader_pos_bwoa_ul;    % N_ul x K matrix
            jidx = find(temp1(i, :) == 1); % double == UE i uses subchannel jidx 

            % bs: base station that the UE offloads to
            bs    = find(UE_BS(i, :) == 1);
            bs_   = UEs.inBS(i);   % bs and bs_ are supposed to be equal

            % k: offloading users to subcs j that its gain smaller than i's gain
            xkj = (temp1(:, jidx) > 0) & (diag(ChannelGain.h2h(1:N_ul, :, bs, jidx)) < ChannelGain.h2h(i, i, bs, jidx));
                    % xkj == N_ul x 1 boolean matrix
            
            % data rate  %% float
            Rij_MEC(i) = params.B_k *log2(1 + (leader_pos_woa(i)* ChannelGain.h2h(i, i, bs, jidx))/(params.B_k* noAnten* params.n0 + ...
                sum(xkj.*leader_pos_woa(:).*diag(ChannelGain.h2h(1:N_ul, :, bs, jidx))) + cci_SBS{jidx}(bs) ));
            
            T_r_MEC(i) = D_n/Rij_MEC(i) + C_n/f_i(i);
            E_r_MEC(i) = leader_pos_woa(i)*D_n/(params.zeta *Rij_MEC(i));
        end
%         Z_r_MEC = beta_t.*T_r_MEC + params.beta_e*E_r_MEC;
        
        T_i = loc_idx.*T_l + off_idx.*T_r_MEC; % N_ul x 1
        E_i = loc_idx.*E_l + off_idx.*E_r_MEC; % N_ul x 1
        
        Z_i = params.beta_t.*(T_l - T_i)./T_l + params.beta_e.*(E_l - E_i)./E_l;  % N_ul x 1
        
        su_MEC(iK, iReal) = sum(Z_i);
        ti_MEC(iK, iReal) = sum(T_i);
        en_MEC(iK, iReal) = sum(E_i);
    end
end

po_MEC_mean = mean(po_MEC, 2);
su_MEC_mean = mean(su_MEC, 2);
ti_MEC_mean = mean(ti_MEC, 2);
en_MEC_mean = mean(en_MEC, 2);

xt_beta = cell(1, length(Beta_t));
for i = 1:2:length(Beta_t)
    xt_beta(i) = {num2str(Beta_t(i))};
end

% save('new\preference.mat', 'Beta_t' ,'po_MEC', 'su_MEC', 'ti_MEC', 'en_MEC','users_no');

toc
t = toc