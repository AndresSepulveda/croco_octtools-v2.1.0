function oct_r2r_clean_coefs()
%
%  Delete the interpolation coefficient files r2r_coefs_*.mat of the
%  current folder (they must be recomputed when the grids change).
%
%  Octave version (Oct-2026). This is a function, so that a variable
%  named "dir" (or "delete") in the workspace of the calling script
%  cannot shadow the built-in functions (error "dir(...): out of bound").
%
f = dir('r2r_coefs_*.mat');
for k = 1:numel(f)
  delete(f(k).name);
  disp(['Deleted old coefficients: ',f(k).name])
end
return
