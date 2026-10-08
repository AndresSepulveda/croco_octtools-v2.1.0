function [coef1d,elem1d] = oct_get_1d_coef(zp,zc)
%
% Inputs:  parent z (zp), child z (zc), both in ascending order
% Outputs: elem1d - pointers to the 1d parent data (1-2 per child point)
%          coef1d - linear interpolation coefficients
%          fc = sum(coef1d.*fp(elem1d),2)
%
%   Jeroen Molemaker, UCLA  2007. Octave version (Oct-2026).
%
Np = numel(zp);
Nc = numel(zc);
coef1d = zeros(Nc,2);
elem1d = ones(Nc,2);
ip = 1;
for ic = 1:Nc
  while (zp(ip)<zc(ic)) && (ip<Np)
    ip = ip+1;
  end
  if ip == 1 || zp(ip) < zc(ic)
    coef1d(ic,1) = 1.0;
    elem1d(ic,1) = ip;
    continue
  end
  alp = (zc(ic)-zp(ip-1))/(zp(ip)-zp(ip-1));
  coef1d(ic,1) = alp;
  elem1d(ic,1) = ip;
  coef1d(ic,2) = 1-alp;
  elem1d(ic,2) = ip-1;
end
return
