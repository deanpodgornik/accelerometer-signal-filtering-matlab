function [result, firstRun, A, H, Q, R, x, P, xp, Pp, K] = Filter_SimpleKalman(z, varianca, firstRun, A, H, Q, R, x, P, xp, Pp, K)

if firstRun ~= 1
  A = 1;
  H = 1;
  
  %Q in R sta dolo�ena pred klicom te funkcije  
  
  %Predpostavka, da je za�etna vrtednost stanja (hitrost oziroma pozicija) 0
  x = 0;
  %apriorna ocena kovariance napake (nesme biti 0, sicer �um ne bo upo�tevan)
  P =  0.1413; %izmerjeno

  firstRun = 1;
  
  xp = 0;
  Pp = 0;
  K = 0;
end

%Time update (takoreko�: KORAK PREDIKCIJE)
% projektira stanje na novo stanje in oceni kovarianco napake (v namen pridobitve naslednjega koraka)
xp = A*x;
Pp = A*P*A' + Q;

%Measurement update (takoreko�: KORAK KOREKCIJE)
% ta korak nam da feedback (za vklju�evanje nove meritve v apriorno oceno)
K = Pp*H'*inv(H*Pp*H' + R);

x = xp + K*(z - H*xp);
P = Pp - K*H*Pp;

%vrnem rezultat
result = x;