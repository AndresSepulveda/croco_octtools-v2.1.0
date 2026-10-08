%
%  oct_rfact: script, r-factor r of the topography hr (Octave version of
%  rfact.m, unchanged).
%

  r1 = 0.*hr;
  r2 = 0.*hr;
  r1(1:end-1,:) = 0.5*(hr(2:end,:) - hr(1:end-1,:))./( hr(2:end,:) + hr(1:end-1,:) );
  r2(:,1:end-1) = 0.5*(hr(:,2:end) - hr(:,1:end-1))./( hr(:,2:end) + hr(:,1:end-1) );
  r = max(abs(r1),abs(r2));

