%----------------------------------------------------------------------------
% apply BWOA algorithm and condition 1 and 2 to solve UL pb.
%----------------------------------------------------------------------------

% Output:
% BWOA_result == struct with
    % leader_score == double
    % leader_pos   == (N_ul + M_dl) x K matrix
    % conver_curve == 1 x ?
% WOA_result  == struct with
    % leader_pos_ul   == N_ul x 1 matrix
    % leader_pos_dl   == N_dl x M_dl matrix
    % conver_curve_ul == 1 x ?1
    % conver_curve_dl == 1 x ?2
    % no_WOA_run      == double

    function [BWOA_result, WOA_result, time] = int_WOA(functionName_, doTol, UEs, BS, UE_BS, fobj_bwoa, fobj_woa, fobj_woa_dl, h2h, params, var) 
    eta = var.eta;
    maxIter = params.maxIter;
    noSearchAgents = params.noSearchAgents;
    noSubcs = params.noSubcs;

    WOA_rs    = 0;
    WOA_rs_dl = 0;
tic 
    N_ul = UEs.total(1);
    N_dl = UEs.total(2);
    M_dl = BS.total(2);

	% initialization ======
    [positions] = Initialization2(functionName_, noSubcs, UEs, BS, UE_BS, noSearchAgents, var.Adet);
	        % positions = (N_ul + M_dl) x K x noSA  matrix == position of noSA binary whales
  
	leader_pos_bwoa = zeros(N_ul+M_dl, noSubcs); % position of the whale that makes the obj function get the best fitted value
	leader_score_bwoa = -inf; % value of the best fitted obj function
	leader_score_pre = leader_score_bwoa; 
	
    % leader_score_woa 
    pos_woa = zeros(N_ul, 1);
	leader_pos_woa = zeros(N_ul, 1); 
    pos_woa_dl = zeros(N_dl, M_dl);
    leader_pos_woa_dl = zeros(N_dl, M_dl); 
    leader_pos_woa_dl(:,:) = params.P_SBS_min;

	% loop counter
	% doTol = 0; % = doTol == 0 to check all 1000 iterations
	delta = 1e-5; 
	flag = 0; 
	
	conver_curve = zeros(1, maxIter);
    conver_curve_woa = zeros(1, maxIter); 
    conver_curve_woa_dl = zeros(1, maxIter); 
    
	C_Step = zeros(N_ul + M_dl, 1); % (N_ul + M_dl) x 1
	iter = 0; 
	phi = @(y,a,x,eta) y*log2(1 + a*x) - (a/log(2))*(eta + y*x)/(1 + a*x);
    fmin = @(y,a,x,eta) (eta+y*x)/(params.B_k*log2(1 + a*x)); 
	
	varepsilon = 1e-5 ;
 
	no_WOA_run = 0; 

	while iter < maxIter
 %       display(['iter = ' num2str(iter)]);  
 %        whale_no = 0; 
		for nSA = 1:noSearchAgents
%            fprintf('BWOA iter:%i/%i\n', iter, maxIter)
%            fprintf('SearchAgent no %i/%i\n', nSA, noSearchAgents)
            fitbwoa = fobj_bwoa(positions(:, :, nSA)); 
 %           display([k fitbwoa score_bwoa leader_score_bwoa]);

			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			% define constraint to cut down on the number of WOA runs
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			
            if ~strcmp(functionName_, 'ALCA')
			    % condition 1
			    if fitbwoa > 1e2 || fitbwoa <= leader_score_bwoa
				    continue
			    end 
    
                % check condition 2
			    % condition 2
                %tic
			    WOA_tmp = 0; 
                p_tmp = zeros(N_ul,1);
                % p_tmp = zeros(noUsers,1);
                % bisection    
                for n = 1: (N_ul)
                    m = find(UE_BS(n,:)>0); % SBS that covers UE n
                    for k = 1:noSubcs
                        if positions(n, k, nSA) == 0
                            continue;
                        end
                        if phi(var.theta(n), h2h(n, n, m, k)/(params.n0), params.p_max, eta(n)) <= 0
                            p_tmp(n) = params.p_max;
                        else
                            p_s = params.p_min; 
                            p_t = params.p_max;
                            while (abs(p_t - p_s) > varepsilon)
                                p_l = (p_t + p_s)/2;
                                if phi(var.theta(n), h2h(n, n, m, k)/(params.n0), p_l, eta(n)) <= 0
                                    p_s = p_l;
                                else
                                    p_t = p_l;
                                end
                            end
                            p_tmp(n) = (p_s + p_t)/2;
                        end
                        WOA_tmp = WOA_tmp + fmin(var.theta(n), h2h(n, n, m, k)/(params.n0), p_tmp(n), eta(n));
                    end
                end
    
                if (fitbwoa - WOA_tmp) <= leader_score_bwoa
                    continue
                end 
                %toc
                %t1 = toc;
     %           fprintf('old_time for condition 2: %i', t1);
    
                no_WOA_run = no_WOA_run + 1; 
                
                if (strcmp(functionName_,'ARJOA') || strcmp(functionName_, 'WOA_SIC_MEC')|| strcmp(functionName_, 'IOJOA')|| strcmp(functionName_, 'OFDMA'))
                    if N_ul > 0
                        [WOA_rs, pos_woa, ~] = WOA(noSearchAgents, ...
				            N_ul, params.maxIter_woa, var, fobj_woa, leader_pos_woa_dl, positions(:,:,nSA));
                    end
                    
                    if N_dl>0
                        if (iter==0)&&(nSA==1)
                            leader_pos_woa = pos_woa;
                        end
                        [WOA_rs_dl, pos_woa_dl, ~] = WOA_dl(noSearchAgents, ...
				            N_dl, M_dl, UE_BS, params.maxIter_woa, var, fobj_woa_dl, leader_pos_woa, positions(:,:,nSA));
                    end
                elseif strcmp(functionName_,'IWOA_SIC_MEC')
                    if N_ul > 0
                        [WOA_rs, pos_woa, ~] = IWOA(noSearchAgents, ...
				            N_ul, params.maxIter_woa, var, fobj_woa, leader_pos_woa_dl, positions(:,:,nSA));
                    end
                    
                    if N_dl>0
                        if (iter==0)&&(nSA==1)
                            leader_pos_woa = pos_woa;
                        end
                        [WOA_rs_dl, pos_woa_dl, ~] = IWOA_dl(noSearchAgents, ...
				            N_dl, M_dl, UE_BS, params.maxIter_woa, var, fobj_woa_dl, leader_pos_woa, positions(:,:,nSA));
                    end
                elseif strcmp(functionName_, 'PSO_SIC_MEC')
                    if N_ul > 0
                        [WOA_rs, pos_woa, ~] = PSO(noSearchAgents, ...
				            N_ul, params.maxIter_woa, var, fobj_woa, leader_pos_woa_dl, positions(:,:,nSA));
                    end
                    
                    if N_dl>0
                        if (iter==0)&&(nSA==1)
                            leader_pos_woa = pos_woa;
                        end
                        [WOA_rs_dl, pos_woa_dl, ~] = PSO_dl(noSearchAgents, ...
				            N_dl, M_dl, UE_BS, params.maxIter_woa, var, fobj_woa_dl, leader_pos_woa, positions(:,:,nSA));
                    end
                end
            elseif strcmp(functionName_, 'ALCA')
                WOA_rs = 0;
                if N_dl>0
                    if (iter==0)&&(nSA==1)
                        leader_pos_woa = pos_woa;
                    end
                    [WOA_rs_dl, pos_woa_dl, ~] = WOA_dl(noSearchAgents, ...
                        N_dl, M_dl, UE_BS, params.maxIter_woa, var, fobj_woa_dl, leader_pos_woa, positions(:,:,nSA));
                end
            end
                   
            fitness = fitbwoa - WOA_rs + WOA_rs_dl; % double

			% update the leader
            if fitness >= leader_score_bwoa
                leader_score_bwoa = fitness;
                leader_pos_bwoa   = positions(:, :, nSA);
                leader_pos_woa 	  = pos_woa;
                leader_score_woa  = WOA_rs;

                leader_pos_woa_dl    = pos_woa_dl;
                leader_score_woa_dl  = WOA_rs_dl;
                whale_no          = nSA;
            end
%            fprintf('BWOA fitness Whale no (SA no): %i\n', whale_no)
%            fprintf('BWOA leaderscore: %i\n',leader_score_bwoa)
		end

        a = 2 - iter*(2/maxIter); % a decreases linearly from 2 to 0
		a2 = -1 + iter*(-1/maxIter); % a2 decreases linearly from -1 to -2 
		% update the position of each search agents 
       
        % positions == (N_ul + M_dl) x K x nSA binary matrix
            % convert positions into (N_ul + M_dl) x nSA integer matrix (range 1-K)
        int_positions = zeros(N_ul+M_dl, noSearchAgents);
        for nSA = 1: noSearchAgents
            for i = 1:size(positions, 1)
                % Find the position of 1 in the current row
                indices = find(positions(i, :, nSA) == 1);
                if length(indices) ==1  
                    % Store the result in the corresponding position in the result vector
                    int_positions(i, nSA) = indices;
                end
            end
            % int_positions == (N_ul + M_dl) x 1 integer matrix (range 1-K)
        end
        
        % leader_pos_bwoa == (N_ul + M_dl) x K
        int_leader_pos_bwoa = zeros(N_ul + M_dl,1); % (N_ul + M_dl) x 1
        for i = 1:size(leader_pos_bwoa, 1)
            % Find the position of 1 in the current row
            indices = find(leader_pos_bwoa(i, :) == 1);
            if length(indices)==1
                % Store the result in the corresponding position in the result vector
                int_leader_pos_bwoa(i) = indices;
            end
        end

        %tic
        for nSA = 1:noSearchAgents
            r1 = rand();
            r2 = rand();
            A = 2*a*r1 - a;
            C = 2*r2;
            % parameters for spiral updating position
            b = 1;
            l = (a2 - 1)*rand + 1;
            p = rand();
            if ~strcmp(functionName_, 'ALCA')
                for n = 1: (N_ul+M_dl)
                    if p < 0.5
                        % search for prey (exploration phase)
                        if abs(A) >= 1
                            rand_idx = floor(noSearchAgents*rand + 1);
                            X_rand   = int_positions(:, rand_idx); % (N_ul + M_dl) x 1 matrix
                            D_X_rand = abs(C*X_rand(n) - int_positions(n, nSA)); % double
                            int_positions(n,nSA) = round(X_rand(n) - A*D_X_rand); 
                        elseif abs(A) < 1
                            % shrinking encircling mechanism (exploitation phase)
                            D_leader = abs(C*int_leader_pos_bwoa(n) - int_positions(n, nSA)); % double
                            int_positions(n,nSA) = round(int_leader_pos_bwoa(n) - A*D_leader);
                        end
                    elseif p >= 0.5
                        distance2leader = abs(int_leader_pos_bwoa(n) - int_positions(n, nSA)); % double
                        int_positions(n, nSA) = round(distance2leader*exp(b.*l).*cos(l.*2*pi) + int_leader_pos_bwoa(n));
                    end
                end
            elseif strcmp(functionName_, 'ALCA')
                for n = (N_ul+1): (N_ul+M_dl)
                    if p < 0.5
                        % search for prey (exploration phase)
                        if abs(A) >= 1
                            rand_idx = floor(noSearchAgents*rand + 1);
                            X_rand   = int_positions(:, rand_idx); % (N_ul + M_dl) x 1 matrix
                            D_X_rand = abs(C*X_rand(n) - int_positions(n, nSA)); % double
                            int_positions(n,nSA) = round(X_rand(n) - A*D_X_rand); 
                        elseif abs(A) < 1
                            % shrinking encircling mechanism (exploitation phase)
                            D_leader = abs(C*int_leader_pos_bwoa(n) - int_positions(n, nSA)); % double
                            int_positions(n,nSA) = round(int_leader_pos_bwoa(n) - A*D_leader);
                        end
                    elseif p >= 0.5
                        distance2leader = abs(int_leader_pos_bwoa(n) - int_positions(n, nSA)); % double
                        int_positions(n, nSA) = round(distance2leader*exp(b.*l).*cos(l.*2*pi) + int_leader_pos_bwoa(n));
                    end
                end
            end
        end
        
        int_positions(int_positions>noSubcs) = noSubcs;
        int_positions(int_positions<0) = 1;

        % convert back
        for nSA = 1: noSearchAgents
            for i = 1:size(positions, 1) % N_ul + M_dl
                if int_positions(i,nSA)~=0
                    positions(i, int_positions(i,nSA), nSA) = 1;
                end
            end
        end

        % make sure DL association to be reasonable
        fl_ = sum(UE_BS,1)>0;         % 1 x M
        fl_ = fl_(1,BS.total(1)+1 :end)';  % M_dl x 1
        positions((N_ul+1):end, :) = positions((N_ul+1):end, :) .* fl_;

        %toc
 %       t2 = toc;
 %       fprintf('old_time for searching is: %i', t2);

        
		iter = iter + 1;
%         fprintf('iter %i\n', iter);
		conver_curve(iter) = leader_score_bwoa; 
		conver_curve_woa(iter) = leader_score_woa;
		conver_curve_woa_dl(iter) = leader_score_woa_dl;

        if ((iter >2) && (conver_curve_woa_dl(iter-1) ~= leader_score_woa_dl))
		    fprintf('iter:%i/%i, leader_score_woa:%i, leader_score_bwoa: %i\n', iter, maxIter, leader_score_woa, leader_score_bwoa)
        end

		if doTol == 1 && iter > 5 && abs(leader_score_bwoa - leader_score_pre) < delta 
                                 %600 for general, 100 for comparing
                                 %old_new
            flag = flag + 1; 
		else 
			flag = 0; 
		end 
		leader_score_pre = leader_score_bwoa; 
		if flag == 20
                %200 for general, 20 for comparing old_new
			conver_curve = conver_curve(1, 1:iter); 
			conver_curve_woa = conver_curve_woa(1:iter); 
			conver_curve_woa_dl = conver_curve_woa_dl(1:iter); 
			break; 
		end 
	end
	toc
	time = toc;
    BWOA_result.leader_score = leader_score_bwoa;
    BWOA_result.leader_pos   = leader_pos_bwoa; 
    BWOA_result.conver_curve = conver_curve;

    WOA_result.leader_pos_ul = leader_pos_woa;
    WOA_result.leader_pos_dl = leader_pos_woa_dl;
    WOA_result.conver_curve_ul = conver_curve_woa;
    WOA_result.conver_curve_dl = conver_curve_woa_dl;
    WOA_result.no_WOA_run = no_WOA_run;
end 