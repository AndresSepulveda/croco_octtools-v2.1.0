function [lonc,latc] = oct_fix_outside_child(lonc,latc,t)
%
%  Move the child points that are outside the parent grid (t not finite,
%  from tsearch/tsearchn) onto their nearest inside child neighbour.
%  These points should be masked in the child grid.
%
%  Octave version (Oct-2026) of fix_outside_child.m (J. Molemaker, UCLA).
%
[Mc,Lc] = size(lonc);
disp('Fixing outside child points, make sure these are masked');
out = ~isfinite(t(:));
%
% move the outside points far away and find the nearest inside neighbour
%
val_lonc = lonc(:);
val_latc = latc(:);
val_lonc(out) = val_lonc(out) + 1000;
val_latc(out) = val_latc(out) + 1000;
val_tri = delaunay(val_lonc,val_latc);
Xc    = [lonc(:) latc(:)];
Xval  = [val_lonc val_latc];
nearel = dsearchn(Xval,val_tri,Xc);
val_lonc(out) = val_lonc(nearel(out));
val_latc(out) = val_latc(nearel(out));
lonc = reshape(val_lonc,Mc,Lc);
latc = reshape(val_latc,Mc,Lc);
return
