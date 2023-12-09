function count = test(N_ul,M_dl,K)

sa = zeros(N_ul + M_dl, K);
count = 0;
xx = ((K+1)^N_ul)* K^M_dl
TRY(1)
    function [] = solution()
        count = count +1;
    end

function [] = TRY(n)
        for j = 0:K
            if j ~= 0
                sa(n, j) = 1;
            end
            if n == N_ul
                if M_dl == 0
                    solution();
                elseif M_dl>0
                    TRY2(1);
                end
            else
                TRY(n + 1);
            end
            if j ~= 0
                sa(n, j) = 0;
            end
        end
    end

    function [] = TRY2(m)
        for k = 1:K
            sa(N_ul+m, k) = 1;
            if m == M_dl
                solution();
            else
                TRY2(m+1);
            end
            sa(N_ul+m, k) = 0;
        end
    end
end