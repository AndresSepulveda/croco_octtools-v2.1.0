function [z,Cs] = oct_zlevs3(h,zeta,theta_s,theta_b,hc,N,type,scoord)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [z,Cs] = oct_zlevs3(h,zeta,theta_s,theta_b,hc,N,type,scoord)
%
%  Depth of rho or w points for ROMS/CROCO.
%
%  On Input:
%    h, zeta     (M,L) topography and free surface
%    type        'r': rho point 'w': w point
%    scoord      'old1994' (Song, 1994),
%                'new2006' (Sasha, 2006)
%                'new2008' bottom stretching included (Sasha, 2008)
%                          = CROCO Vtransform=2 with the theta_b
%                            stretching of oct_csf
%  On Output:
%    z           Depths (m) of RHO- or W-points (N,M,L)
%    Cs          stretching curve (N or N+1)
%
%  Copyright (c) 2002-2006 by Pierrick Penven (ROMSTOOLS, GNU GPL)
%  modified by Yusuke Uchiyama, UCLA, 2008
%  further modified by Evan Mason, UCLA, 2008
%  Octave version (Oct-2026): string comparisons with strcmp ('=='
%  failed for strings of different length), sc.^2 in CSF, no
%  Fortran-style 1.D0 constants.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<8
  error('Not enough input arguments')
end
scoord = lower(strtrim(scoord));
if ~any(strcmp(scoord,{'old1994','new2006','new2008'}))
  error(['oct_zlevs3: unknown s-coordinate type ''',scoord,...
         ''' (old1994, new2006 or new2008)'])
end
[M,L] = size(h);
%
% S-Curves in domain [-1 < sc < 0] at vertical W- and RHO-points.
%
if type=='w'
  sc = ((0:N) - N) / N;
  N = N + 1;
else
  sc = ((1:N)-N-0.5) / N;
end
if strcmp(scoord,'new2008')
  Cs = CSF(sc,theta_s,theta_b);
else
  cff1 = 1./sinh(theta_s);
  cff2 = 0.5/tanh(0.5*theta_s);
  Cs = (1.-theta_b) * cff1 * sinh(theta_s * sc)...
      + theta_b * (cff2 * tanh(theta_s * (sc + 0.5)) - 0.5);
end
%
% Depths
%
z = zeros(N,M,L);
if strcmp(scoord,'old1994')
  disp('--- using old s-coord')
  hinv = 1./h;
  cff  = hc*(sc-Cs);
  cff1 = Cs;
  for k=1:N
    z0 = cff(k)+cff1(k)*h;
    z(k,:,:) = z0+zeta.*(1.+z0.*hinv);
  end
else
  if strcmp(scoord,'new2006')
    disp('--- using new s-coord (2006)')
  end
  hinv = 1./(h+hc);
  cff  = hc*sc;
  cff1 = Cs;
  for k=1:N
    z(k,:,:) = zeta+(zeta+h).*(cff(k)+cff1(k)*h).*hinv;
  end
end
return
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Cs = CSF(sc,theta_s,theta_b)
if (theta_s > 0.0)
  csrf = (1.-cosh(theta_s*sc))/(cosh(theta_s)-1.);
else
  csrf = -sc.^2;
end
sc1 = csrf+1.0;
if (theta_b > 0.0)
  Cs = (exp(theta_b*sc1)-1.0)/(exp(theta_b)-1.0) - 1.0;
else
  Cs = csrf;
end
return
