%------------------------------------------------------------------
% Obtain the objective function and search domain for DL WOA and BWOA.
%------------------------------------------------------------------

% Output:
% lb_woa == N x M matrix == lower bound of power transmission of M SBSs to N UEs
% ub_woa == N x M matrix == upper bound of power transmission of M SBSs to N UEs
% fobj_woa  == 'string'  == @function name of woa
% fobj_bwoa == 'string'  == @function name of bwoa

function [fobj_woa, fobj_bwoa] = getFunctionDetails_dl(F, noUsers, noSubcs, noBSs, UE_BS, hArray, P_SBS_max, gam_th, n0, W, nu)
% F function name: F: depends on each simulation schemes {ARJOA, ODSTCA, IOJOA, OFDMA} 
% network size: noBSs x noSubcs == N x M x K
% UE_BS     == N x M matrix   == binary matrix of relation of UEs and BSs
% hArray    == N x M x K cell - each cell is a L x 1 vector
%            channel gain of UE n to SBS m via subchannel k
% P_SBS_max == 1 x M vector   == SBS power budget  
% gam_th    == threshold of SINR 
% thermal noise: n0
% W: bandwidth of subchannel
% penalty factor for constraint dealing: <double> nu (here, in this code; but in pdf, they are nu and lambda)
% Adet 	  == N x 1 == matrix defines offloading decision of IOJOA: 
    
%     noUsers = size(UEs.active, 1);   % N
%     noBSs   = size(BS.positions, 1); % M

	lb_woa = zeros(noUsers, noBSs);          % N x M == lower bound of power transmission of M SBSs to N UEs
	ub_woa = P_SBS_max.* ones(noUsers,1);    % N x M == upper bound
    if length(P_SBS_max) == 1
        P_SBS_max = P_SBS_max * UE_BS;
    end

% 	PMin = zeros(noUsers, 1); 
% 	PMax = zeros(noUsers, 1); 

% 	PMin(:) = p_min; 
% 	PMax(:) = p_max; 

	switch F
	case 'MEC_NOMA_DL'
		fobj_woa = @FWOA_dl; 
% 		lb_woa(:) = p_min; 
% 		ub_woa(:) = p_max;
		fobj_bwoa = @FBWOA_dl;
    end

%% Calculate beamforming matrix w_mn == Lx1 vector 
W_beam = cell(1, noBSs); % 1 x M cell, each cell is a L x N_m x K matrix
                                        % N_m is the number of UEs in cell m
% hArray == NxMxK cell - each cell is 1 Lx1 vector
% Need to extract H_m == L x N_m  x K from hArray (N_m == number of UEs in cell m)

% H_incell = cell(1, noBSs); % 1 x M cell, each cell is L x N_m x K matrix
                                                    %  == channel gains of UEs in 1 cell

for m = 1: noBSs
    % get indexes of UEs in cell m
    UEs_m = UE_BS(:,m)>0;
    if sum(UEs_m > 0)
        % get channel gains of UEs in cell m
        temp     = hArray(UEs_m', m, :);     % N_m x 1 x K cell of L x 1 vector
        temp     = permute(temp, [2 1 3]);   % 1 x N_m x K cell of L x 1 vector
        H_incell = cell2mat(temp); %         % L x N_m x K matrix 
        %     H_incell{m} = cell2mat(temp);  % L x N_m x K matrix 
    
        for kk = 1:noSubcs
            W_beam{m} (:,:,kk) = H_incell(:,:, kk) / ((H_incell(:,:, kk)' * H_incell(:,:, kk)));
                                   % L x N_m matrix
        end
    end
end


%%
    function o = FWOA_dl(P, X) 
		% P     == N x M matrix          == matrix of transmission power 
		% X     == M x K binary matrix   == association SBSs-subchannels
        % UE_BS == N x M constant matrix == association UEs-SBSs 

	% C7: no need this constraint if we only consider the transmit power of
                % the  SBS to its associating UEs
          % we need this constraint if we take the sum of all elements in P (== M x N matrix)
%     fc7 = P;             % N x M   
%     flag_fc7 = fc7 >= 0; % == G(f(x))
%     pnal_fc7 = sum(sum(nu.* ((UE_BS - (fc7>0) ~=0) ).* flag_fc7.*(fc7.^2)));  %% penalty function for 51-l 
%     rs = rs - pnal_fc7;

    % Constraint 51-m
    pnal_fc8 = 0;

    P_mn = P.*UE_BS ; % N x M  % only consider the transmit power of SBS to its associating UEs
    BS_broad = find(sum(UE_BS, 1)>0); % 1 x ?? vector of broadcasting SBSs (SBS cells that have UEs) 
    for m = BS_broad
        norm_w2  = zeros(1, length(W_beam{m}(1,:,1)) );    % 1 x N_m
        W_beam_m = 0;
        for k = 1: noSubcs
            W_beam_m = W_beam_m + X(m, k) * W_beam{m}(:,:,k); % L x N_m
                              % with m pre-defined, X(m,k) =1 for just 1 value of k
        end 
        for n = 1: length(W_beam{m}(1,:,1)) % for n = 1 to N_m
            norm_w2(n) = norm(W_beam_m(:,n)) ^2; % 1 x N_m
                                            %  norm ^2 of w_mn
        end
        P_m = P_mn(:,m);     % N x 1
        P_m = P_m(P_m>0);    % N_m x 1
        fc8_m = 0;
        for nn = 1: length(P_m) % for nn = 1 to N_m
             fc8_mn = P_m(nn) * norm_w2(nn);
             fc8_m  = fc8_m + fc8_mn;
        end
        fc8_m = fc8_m - P_SBS_max(m);
        flag_fc8m = fc8_m >0;
        pnal_fc8 = pnal_fc8 + nu.* flag_fc8m.*(fc8_m.^2);
    end
    
    penal_fc9 = 0;
    gamma_dl  = zeros(noBSs, noUsers); % == M x N
    R_dl      = zeros(noBSs, noUsers, noSubcs);  % M x N x K

    for k = 1:noSubcs
		Xk = X(:,k);		% Xk == M x 1 vector == association vector regarding to subchannel k

		% Find the BSs broadcasting via subchannel k
		BS_no  = find(Xk>0);  	%  ?1 x 1 vector
									%  == indexes of BSs that broadcasting via subchannel k
	    if (isempty(BS_no)) 
            continue 			% no SBS broadcast via subchannel k --> go check k+1
        elseif length(BS_no) == 1  
            % find UEs in cell
            UEs_m = find(UE_BS(:,BS_no) >0);  % ?2 x 1 vector 

            % Constraint
            for n = UEs_m'
                fc9_mn     = W*n0 * gam_th - P(n,BS_no);  
                flag_fc9mn = fc9_mn >0;
                penal_fc9_mn = sum(sum(nu.* flag_fc9mn.*(fc9_mn.^2)));
                penal_fc9    = penal_fc9 + penal_fc9_mn;
                % if penal_fc9< 1*10^(-7)
                %     penal_fc9 = 0;
                % end

                gamma_dl(BS_no,n)= P(n,BS_no) / (W*n0);
                R_dl(BS_no,n,k) = W.*log2(1+gamma_dl(BS_no,n));                
            end
%         interf = 0; % interference
        elseif length(BS_no) > 1 % exist inter-cell interference										        
		    for m = BS_no'
                % find UEs in cell m
                UEs_m = find(UE_BS(:,m) >0);  % ?2 x 1 vector 

                % find cell j also use subchannel k; j <> m
                BS_not_m = BS_no';
                BS_not_m(BS_not_m == m) = [];  % 1 x ?3 vector

                for  n = UEs_m'
                    inn = 0;
                    for j = BS_not_m
                        P_j = P(:,j);                % N   x 1 vector 
                        P_j = P_j(UE_BS(:,j) >0);    % N_j x 1 vector
                                % change the dimension to N_j x 1 to be in
                                % harmony with W{j}(:,:,k) == L x N_j
                        for i = 1:length(P_j) % for i = 1 to N_j
                            inn = inn + P_j(i) * abs( hArray{n,j,k}'* W_beam{j}(:,i,k))^2;
                        end
                    end
                    inn = inn + W*n0;
                    gamma_dl(m,n)= P(n,m) / inn; 
                    fc9_mn       = gam_th*inn - P(n,m);
                    flag_fc9mn   = fc9_mn >0;
                    penal_fc9_mn = sum(sum(nu.* flag_fc9mn.*(fc9_mn.^2)));
                    penal_fc9    = penal_fc9 + penal_fc9_mn;
                  
                    R_dl(m,n,k) = W.*log2(1+gamma_dl(m,n)); 
                end
            end
            
        end
        
    end
    o = sum(sum(sum(R_dl))) - penal_fc9 - pnal_fc8;
end

%%
function o = FBWOA_dl(X,P)
	% X == M x K matrix = SBS-subchannel asociation matrix
    % P == N x M matrix = transmit power allocation
    
	% constraint dealing 
 		% Constraint 
 		A_m = sum(X,2); 	    % M x 1 vector
 		fc_A_dl  = A_m -1;		% M x 1
        flag_fcA = fc_A_dl >0;
       
 		pnal_fcA_dl = sum(nu.*flag_fcA.*(fc_A_dl.^2));

 	% objective function
 	gamma_dl  = zeros(noBSs, noUsers); % == M x N
    R_dl      = zeros(noBSs, noUsers, noSubcs);  % M x N x K

        for k = 1:noSubcs
		Xk = X(:,k);		% Xk == M x 1 vector == association vector regarding to subchannel k

		% Find the BSs broadcasting via subchannel k
		BS_no  = find(Xk>0);  	%  ?1 x 1 vector
									%  == indexes of BSs that broadcasting via subchannel k
	    if (isempty(BS_no)) 
            continue 			% no SBS broadcast via subchannel k --> go check k+1
        elseif length(BS_no) == 1  % no inter-cell interference
            % find UEs in cell m
            UEs_m = find(UE_BS(:,BS_no) >0);  % N_m x 1 vector 

            % Constraint
            for n = UEs_m'
                gamma_dl(BS_no,n)= P(n,BS_no) / (W*n0);
                R_dl(BS_no,n,k) = W.*log2(1+gamma_dl(BS_no,n));                
            end
%         interf = 0; % interference
        elseif length(BS_no) > 1 % exist inter-cell interference										        
		    for m = BS_no'
                % find UEs in cell m
                UEs_m = find(UE_BS(:,m) >0);  % ?2 x 1 vector 

                % find cell j also use subchannel k; j <> m
                BS_not_m = BS_no';
                BS_not_m(BS_not_m == m) = [];  % 1 x ?3 vector

                for  n = UEs_m'
                    inn = 0;
                    for j = BS_not_m
                        P_j = P(:,j);                % N   x 1 vector 
                        P_j = P_j(UE_BS(:,j) >0);    % N_j x 1 vector
                                % change the dimension to N_j x 1 to be in
                                % harmony with W{j}(:,:,k) == L x N_j
                        for i = 1:length(P_j) % for i = 1 to N_j
                            inn = inn + P_j(i) * abs( hArray{n,j,k}'* W_beam{j}(:,i,k))^2;
                        end
                    end
                    inn = inn + W*n0;
                    gamma_dl(m,n)= P(n,m) / inn;                     
                                        
                    R_dl(m,n,k) = W.*log2(1+gamma_dl(m,n)); 
                end
            end
            
        end
        
    end

	o = sum(sum(sum(R_dl))) - pnal_fcA_dl; %

end 
end