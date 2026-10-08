function fm = oct_fillmask(f,type,maskp,nnel)
%
%  Put values in the masked points that are based on nearest
%  non-masked neighbour or zero (type = 1/0)
%  This take the place of 'fill missing value' and 'nonan'
%
%  input:  f      2d (M,L) or 3d (N,M,L) grid of values to be mask filled
%          type   mask extension type: 0 zeros / 1 nearest neighbor
%                 extrapolation
%          maskp  2d land/sea mask (M,L)
%          nnel   2d pointer to the nearest non-masked neighbour
%                 (from oct_get_tri_coef)
%  output: fm     2d or 3d grid of values that are filled
%
%  (c) 2007, Jeroen Molemaker,  UCLA
%  Octave version (Oct-2026): vectorized, same results.
%
land = find(maskp==0);
if ndims(f)==3
  [n,m,l] = size(f);
  f2 = reshape(f,n,m*l);
  if type==1          % nearest neighbor extrapolation
    f2(:,land) = f2(:,nnel(land));
  else                % zeros
    f2(:,land) = 0;
  end
  fm = reshape(f2,n,m,l);
else
  if type==1
    f(land) = f(nnel(land));
  else
    f(land) = 0;
  end
  fm = f;
end
return
