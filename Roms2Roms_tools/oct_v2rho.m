function vr = oct_v2rho(v)
%
%  v-points to rho-points (2d (M-1,L) or 3d (N,M-1,L)), boundary values
%  copied.  2007, Jeroen Molemaker, UCLA. Octave version (Oct-2026).
%
if ndims(v)==2
  [M,Lp] = size(v);
  vr = zeros(M+1,Lp);
  vr(2:M,:) = 0.5*(v(1:M-1,:)+v(2:M,:));
  vr(1,:)   = v(1,:);
  vr(M+1,:) = v(M,:);
else
  [Np,M,Lp] = size(v);
  vr = zeros(Np,M+1,Lp);
  vr(:,2:M,:) = 0.5*(v(:,1:M-1,:)+v(:,2:M,:));
  vr(:,1,:)   = v(:,1,:);
  vr(:,M+1,:) = v(:,M,:);
end
return
