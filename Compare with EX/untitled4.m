clear U
a1 = 2;
a2 = a1 + 2;
a3 = a2 + 3;
a4 = a3 + 15;
a5 = a4 + 50;
a6 = a5 + 30;
a7 = a6 + 79;
a8 = a7 + 1;

U(1, 1:a1) = 5.538221e-01;
U(1, a1+1:a2) = 1.0938897e+00;
U(1, a2+1:a3) = 2.3938897e+00;
U(1, a3+1:a4) = 3.5718125;
U(1, a4+1:a5) = 3.6008645;

figure
plot(1:length(U), U );
hold
plot(1:length(U), 3.6086*ones(1,length(U)));