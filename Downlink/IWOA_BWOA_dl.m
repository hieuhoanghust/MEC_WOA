%----------------------------------------------------------------------------
% apply BWOA algorithm for DL.
%----------------------------------------------------------------------------

% leader_score_bwoa == double
% leader_pos_bwoa 	== M x K matrix
% leader_pos_woa    == N x M matrix

function [leader_score_bwoa, leader_pos_bwoa, leader_pos_woa, conver_curve, conver_curve_woa, no_WOA_run, time] = IWOA_BWOA_dl(functionName, noSearchAgents, noUsers, noSubcs, noBSs, UE_BS, maxIter, fobj_bwoa, P_SBS_min, P_SBS_max, fobj_woa)

tic 

	% initialization ======
	[positions, ~] = Initialization_dl(functionName, noUsers, noSubcs, noBSs, UE_BS, P_SBS_min, P_SBS_max, noSearchAgents);
		% positions == M x K x noSA matrix == position of noSA binary whales
		% ~         == N x M x noSA matrix

	leader_pos_bwoa = zeros(noBSs, noSubcs); % == M x K
                                             % position of the whale that makes the obj function get the best fitted value
	leader_score_bwoa = -inf; % value of the best fitted obj function
	leader_score_pre = leader_score_bwoa;  % leader_score_woa in the previous iteration
	leader_pos_woa = zeros(noUsers, noBSs); 


	% loop counter
	doTol = 0; % = doTol == 0 to check all iterations
	delta = 1e3; 
	flag = 0; 
	
	conver_curve = zeros(1, maxIter);
    conver_curve_woa = zeros(1, maxIter); 
	C_Step = zeros(noBSs, noSubcs); 
	iter = 0; 	
 
	no_WOA_run = 0; 

	while iter < maxIter
 %       display(['iter = ' num2str(iter)]);  
        whale_no = 0; 
        whale_no_pre = 0;
		for nSA = 1:noSearchAgents
%            fprintf('BWOA iter:%i/%i\n', iter, maxIter)
%            fprintf('SearchAgent no %i/%i\n', nSA, noSearchAgents)

 %           display([k fitbwoa score_bwoa leader_score_bwoa]);

						
            %toc
            %t1 = toc;
 %           fprintf('old_time for condition 2: %i', t1);

            no_WOA_run = no_WOA_run + 1; 
            

            [WOA_rs, pos_woa, ~] = IWOA_dl(noSearchAgents, ...
				noUsers, noBSs, UE_BS, maxIter, P_SBS_min, P_SBS_max, fobj_woa, positions(:,:,nSA));
            
            fitbwoa = fobj_bwoa(positions(:, :, nSA), pos_woa); 
                            % positions == M x K x noSA
                            % pos_woa   == N x M 

            fitness = fitbwoa; % double

			% update the leader
			if fitness > leader_score_bwoa
				leader_score_bwoa = fitness; 
				leader_pos_bwoa   = positions(:, :, nSA); 
				leader_pos_woa 	  = pos_woa; 
				leader_score_woa  = WOA_rs; 
                whale_no          = nSA;
            end 
            
            if whale_no_pre ~= whale_no
                fprintf('BWOA fitness Whale no (SA no): %i\n', whale_no)
                fprintf('BWOA leaderscore: %i\n',leader_score_bwoa)
                whale_no_pre = whale_no;
            end
		end

		a  = 2 - iter*(2/maxIter);   % a decreases linearly from 2 to 0
		a2 = -1 + iter*(-1/maxIter); % a2 decreases linearly from -1 to -2 
		% update the position of each search agents 
        
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
			for k = 1:noSubcs
				for m = 1:noBSs				
						if p < 0.5
							% search for prey (exploration phase)
							if abs(A) >= 1 
								rand_idx = floor(noSearchAgents*rand + 1); 
								X_rand   = positions(:, :, rand_idx); % N x M+1 x K matrix
								D_X_rand = abs(C*X_rand(m, k) - positions(m, k, nSA)); 
								C_Step(m, k) = X_rand(m, k) - A*D_X_rand;
							elseif abs(A) < 1
								% shrinking encircling mechanism (exploitation phase)
								D_leader = abs(C*leader_pos_bwoa(m, k) - positions(m, k, nSA)); 
								C_Step(m, k) = leader_pos_bwoa(m, k) - A* D_leader; 
							end
						elseif p >= 0.5
							distance2leader = abs(leader_pos_bwoa(m, k) - positions(m, k, nSA));
							C_Step(m, k) = distance2leader*exp(b.*l).*cos(l.*2*pi) + leader_pos_bwoa(m, k); 
						end 

						sigmoid = 1/(1 + exp(-10*(C_Step(m, k)-0.5))); 

						p_rand = rand(); 
						if p_rand < sigmoid
							positions(m, k, nSA) = ~positions(m, k, nSA); 
						end 	
				end 
			end
        end
        %toc
 %       t2 = toc;

        
		iter = iter + 1;
        fprintf('iter %i\n', iter);
		conver_curve(iter) = leader_score_bwoa; 
		conver_curve_woa(iter) = leader_score_woa;

		fprintf('iter:%i/%i, leader_score_woa:%i, leader_score_bwoa: %i\n', iter, maxIter, leader_score_woa, leader_score_bwoa)

		if doTol == 1 && iter > 600 && abs(leader_score_bwoa - leader_score_pre) < delta 
                                 %600 for general, 100 for comparing
                                 %old_new
            flag = flag + 1; 
		else 
			flag = 0; 
		end 
		leader_score_pre = leader_score_bwoa; 
		if flag == 200
			conver_curve = conver_curve(1, 1:iter); 
			conver_curve_woa = conver_curve_woa(1:iter); 
			break; 
		end 
	end
	toc
	time = toc;
    plot(1:length(conver_curve), conver_curve);
    hold on
end 