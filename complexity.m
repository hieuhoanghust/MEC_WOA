% complexities
M_ul = 4;
N_ul = 24;
K_ul = 5;
N_ul = ceil(N_ul/M_ul);
p_n= 0.25;
epsi = 10^(-2);

M_dl = 7;
K_dl = 5;
N_dl = 24;

I_1 = 150;
I_2 = 1000;
I_3 = 1000;
I_4 = 150;
S_1 = 30;
S_2 = 30;
S_3 = 30;
S_4 = 30;
S_max = 40;

F_ul_woa  = M_ul * (I_2 * S_2 *(N_ul * log2(p_n/epsi) + I_1 * S_1 * N_ul * K_ul ) )
F_ul_iwoa = M_ul * (I_2 * S_2 *(N_ul * log2(p_n/epsi) + I_1 *S_max* N_ul * K_ul ) )
F_ul_pso  = M_ul * (I_2 * S_2 *(N_ul * log2(p_n/epsi) + I_1 * S_1 * N_ul * K_ul ) )
F_ul_ex   = M_ul * ((K_ul +1)^N_ul *(N_ul * log2(p_n/epsi) + I_1 * S_1 * N_ul * K_ul ) )
% F_ul_ex   = ((K_ul +1)^N_ul *(N_ul * log2(p_n/epsi) + I_1 * S_1 * N_ul * K_ul ) )^M_ul
% sum or product of M_ul cases?

F_dl_woa   = I_3 * S_3 * I_4 * M_dl *(2* S_4 * N_dl + K_dl)
F_dl_iwoa  = I_3 *S_max* I_4 * M_dl *(2* S_4 * N_dl + K_dl)
F_dl_pso   = I_3 * S_3 * I_4 * M_dl *(2* S_4 * N_dl + K_dl)
F_dl_ex    = K_dl^M_dl * I_4 * M_dl *(2* S_4 * N_dl + K_dl)

