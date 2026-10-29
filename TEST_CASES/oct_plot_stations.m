close all
clear all

nc=oct_tc_open('stations.nc','r');
nsta=2;
for ista=1:nsta;
  T=squeeze(oct_tc_sq(oct_tc_var(nc,'temp')(:,ista,:),3,oct_tc_ndims(nc,'temp')));
  D=squeeze(oct_tc_sq(oct_tc_var(nc,'depth')(2,ista,:),3,oct_tc_ndims(nc,'depth')));
  time=oct_tc_all(nc,'scrum_time');                 % scrum_time(time) or scrum_time(time,station)
  if min(size(time))>1, time=time(:,ista); end
  time=time(:)./86400;
  T(1,:)=[];time(1)=[];
  N=length(D); Nt=length(time);

  figure
  for k=1:N;
    plot(time,T(:,k)); hold on;
  end;
  hold off;
  xlabel('Time [days]');
  ylabel('Temperature [deg. C]');

  time2d=repmat(time,1,N);
  D2d=repmat(D,Nt,1);
  figure
  pcolor(time2d,D2d,T); shading flat;
  xlabel('Time [days]');
  ylabel('Depth [m]');
  axis([-Inf +Inf -100 0]);
  caxis([16 24]);colorbar;
  set(gca,'Layer','top');  
end;
oct_tc_close(nc);
