oct_start
crocotools_param
lon=(5:0.5:25)'; lat=(-42:0.5:-22)'; depth=[5 15 25 35 50 75 100 150 200 300 400 500 700 1000 1500 2000 3000 4000 5000]';
NZ=length(depth); [LO,LA]=meshgrid(lon,lat);
land = LO>=18.5 & LA>=-34.5;
for M=1:3
  time=datenum(2005,M,15)-datenum(Yorig,1,1);
  temp=zeros(NZ,length(lat),length(lon)); salt=temp; u=temp; v=temp;
  for k=1:NZ
    t=2+18*exp(-depth(k)/500)*(1+0.1*cos(LA*pi/180))+0.3*M; t(land)=NaN; temp(k,:,:)=t;
    s=34.5+0.8*exp(-depth(k)/800)+0.0*LA; s(land)=NaN; salt(k,:,:)=s;
    uu=0.1*exp(-depth(k)/300)*ones(size(LO)); uu(land)=NaN; u(k,:,:)=uu;
    vv=-0.05*exp(-depth(k)/300)*cos(LO*pi/180); vv(land)=NaN; v(k,:,:)=vv;
  end
  ssh=0.1*sin(LA*pi/180)+0.01*M; ssh(land)=NaN;
  oct_create_OGCM([OGCM_dir,OGCM_prefix,'Y2005M',num2str(M),'.cdf'],lon,lat,lon,lat,lon,lat,depth,time,temp,salt,u,v,ssh,Yorig)
end
