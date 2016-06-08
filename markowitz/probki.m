% liczba wygenerowanych probek
n = 10000;
% liczba probek z obcietego rozkladu
scenarios = 1000;
% wektor wartosci oczekiwanych
mu = [9 8 7 6];
% macierz kowariancji
sigma = [16 -2 -1 -3; -2 9 -4 -1; -1 -4 4 1; -3 -1 1 1];
% macierz R
R = mvnrnd(mu,sigma,n);
% zawezenie wartosci macierzy
min = 5;
max = 12;

dim = size(R);
rows = dim(1);
cols = dim(2);

finalR = [];

for i = 1:rows
    exceedBounds = 0;
    for k = 1:cols
        if (R(i,k) < 5 || R(i,k) > 12)
            exceedBounds = 1;
        end
    end
    if (exceedBounds == 0)
        finalR = [finalR; R(i,:)];
    end
    [frows, fcols] = size(finalR);
    if (frows == scenarios )
        break
    end
end

[frows, fcols] = size(finalR);
Ridx = []
for i = 1:frows
    newRow = [i finalR(i,:)];
    Ridx = [Ridx; newRow];
end
csvwrite('scenarios.dat',Ridx)