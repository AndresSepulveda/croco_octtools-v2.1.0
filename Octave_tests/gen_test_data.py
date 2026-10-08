import numpy as np, netCDF4 as nc, os
D='DATA_IN/'
for d in ['Topo','COADS05','WOA2009']: os.makedirs(D+d,exist_ok=True)
def land(lon,lat):
    lon=np.mod(lon,360)
    return (lon>=18.5)&(lon<=40)&(lat>=-34.5)&(lat<=10)
# topo etopo-like
lon=np.arange(-180,180,1/6.)+1/12.; lat=np.arange(-90,90,1/6.)+1/12.
LO,LA=np.meshgrid(lon,lat)
topo=-(200+4800*np.clip((18.5-np.mod(LO,360))/4.,0,1))  # shelf deepening westward
topo=np.where(land(LO,LA),300.,topo)
f=nc.Dataset(D+'Topo/etopo2.nc','w'); f.createDimension('lon',len(lon)); f.createDimension('lat',len(lat))
f.createVariable('lon','f8',('lon',))[:]=lon; f.createVariable('lat','f8',('lat',))[:]=lat
v=f.createVariable('topo','i2',('lat','lon')); v[:]=topo.astype('i2'); f.close()
# COADS
X=np.arange(0.25,360,0.5); Y=np.arange(-89.75,90,0.5); T=np.arange(0.5,12,1.)
XX,YY=np.meshgrid(X,Y)
fields={'taux':0.05,'tauy':0.08,'netheat':50,'emp':1.,'sst':18,'sat':17,'airdens':1.2,'w3':7,'qsea':12,
        'salinity':35.2,'shortrad':220,'u3':3,'v3':5,'rh':75,'precip':0.1,'longrad':60}
fname={'salinity':'sss'}
for k,base in fields.items():
    fn=fname.get(k,k)
    f=nc.Dataset(D+'COADS05/%s.cdf'%fn,'w',format='NETCDF3_CLASSIC')
    for n,a in [('X',X),('Y',Y),('T',T)]:
        f.createDimension(n,len(a)); f.createVariable(n,'f4',(n,))[:]=a
    data=np.zeros((12,len(Y),len(X)))
    for t in range(12):
        data[t]=base*(1+0.1*np.cos(np.radians(YY))+0.05*np.sin(2*np.pi*(t+0.5)/12)+0.02*np.sin(np.radians(XX)))
    if k=='sst': data=data-0.3*(YY+30)*0  # keep
    mv=-99999.
    data=np.where(land(XX,YY)[None],mv,data)
    if k in ('sst','sat'):   # packed short with scale/offset
        v=f.createVariable(k,'i2',('T','Y','X')); v.set_auto_maskandscale(False)
        v.scale_factor=np.float32(0.01); v.add_offset=np.float32(0.); v.missing_value=np.int16(-32767)
        v[:]=np.where(data==mv,-32767,np.round(data/0.01)).astype('i2')
    else:
        v=f.createVariable(k,'f4',('T','Y','X')); v.set_auto_maskandscale(False); v.missing_value=np.float32(mv); v[:]=data
    f.close()
# WOA2009
X=np.arange(0.5,360,1.); Y=np.arange(-89.5,90,1.)
Zann=np.array([0,10,20,30,50,75,100,125,150,200,250,300,400,500,600,700,800,900,1000,1100,1200,1300,1400,1500,1750,2000,2500,3000,3500,4000,4500,5000,5500.])
Zmon=Zann[:24]
XX,YY=np.meshgrid(X,Y)
for var,name in [('temp','temperature'),('salt','salinity')]:
    for per,Z,nt in [('month',Zmon,12),('ann',Zann,1)]:
        f=nc.Dataset(D+'WOA2009/%s_%s.cdf'%(var,per),'w',format='NETCDF3_CLASSIC')
        Tm=np.arange(0.5,12,1.)[:nt] if nt>1 else np.array([6.])
        for n,a in [('X',X),('Y',Y),('Z',Z),('T',Tm)]:
            f.createDimension(n,len(a)); f.createVariable(n,'f4',(n,))[:]=a
        d=np.zeros((nt,len(Z),len(Y),len(X)))
        for t in range(nt):
            for k,z in enumerate(Z):
                if var=='temp': d[t,k]=2+18*np.exp(-z/500.)*(1+0.1*np.cos(np.radians(YY)))+0.5*np.sin(2*np.pi*t/12)*np.exp(-z/100)
                else: d[t,k]=34.5+0.8*np.exp(-z/800.)+0.1*np.sin(np.radians(YY))
                # land/bottom mask: land + deeper than local topo (westward deeper)
        d=np.where(land(XX,YY)[None,None],-99.9999,d)
        dims=('T','Z','Y','X') if per=='month' else ('Z','Y','X')   # annual: no T dimension (as in WOA2009)
        v=f.createVariable(name,'f4',dims); v.set_auto_maskandscale(False); v.missing_value=np.float32(-99.9999)
        v[:]=d if per=='month' else d[0]
        f.close()
print('ok')
# TPXO7-like tidal file (10 constituents)
os.makedirs(D+'TPXO7',exist_ok=True)
f=nc.Dataset(D+'TPXO7/TPXO7.nc','w')
lon=np.arange(0,360,0.25); lat=np.arange(-80,80.01,0.25)
LO,LA=np.meshgrid(lon,lat); landT=land(LO,LA)
per=np.array([12.4206,12.0,12.6583,11.9672,23.9345,25.8193,24.0659,26.8684,327.8599,661.31])
for t in ['r','u','v']:
    f.createDimension('lon_'+t,len(lon)); f.createDimension('lat_'+t,len(lat))
    f.createVariable('lon_'+t,'f4',('lon_'+t,))[:]=lon; f.createVariable('lat_'+t,'f4',('lat_'+t,))[:]=lat
f.createDimension('periods',10); f.createVariable('periods','f4',('periods',))[:]=per
f.createVariable('h','f4',('lat_r','lon_r'))[:]=np.where(landT,0,4000.)
amp=np.array([0.5,0.2,0.1,0.05,0.07,0.05,0.02,0.01,0.01,0.01])
for t,base in [('ssh','r'),('u','u'),('v','v')]:
    for part in ['r','i']:
        v=f.createVariable('%s_%s'%(t,part),'f4',('periods','lat_'+base,'lon_'+base))
        for p in range(10):
            ph=np.radians(30*p+0.5*LO); a=amp[p]*(1 if t=='ssh' else 100.)
            v[p]=np.where(landT,0,a*(np.cos(ph) if part=='r' else np.sin(ph))).astype('f4')
f.components='M2 S2 N2 K2 K1 O1 P1 Q1 Mf Mm '
f.close()
print('TPXO ok')
