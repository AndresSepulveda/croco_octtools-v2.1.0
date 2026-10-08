function ur = oct_u2rho(u)
%
%  u-points to rho-points (2d (M,L-1) or 3d (N,M,L-1)), boundary values
%  copied.  (c) 2007, Jeroen Molemaker, UCLA. Octave version (Oct-2026).
%
if ndims(u)==2
  [Mp,L] = size(u);
  ur = zeros(Mp,L+1);
  ur(:,2:L) = 0.5*(u(:,1:L-1) + u(:,2:L));
  ur(:,1)   = u(:,1);
  ur(:,L+1) = u(:,L);
else
  [Np,Mp,L] = size(u);
  ur = zeros(Np,Mp,L+1);
  ur(:,:,2:L) = 0.5*(u(:,:,1:L-1) + u(:,:,2:L));
  ur(:,:,1)   = u(:,:,1);
  ur(:,:,L+1) = u(:,:,L);
end
return
