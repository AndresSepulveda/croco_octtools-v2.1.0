import numpy as np, netCDF4 as nc, sys
from scipy.interpolate import griddata
P=nc.Dataset('PAR/croco_grd.nc'); C=nc.Dataset('CHD/croco_grd.nc'); H=nc.Dataset('PAR/croco_avg.00010.nc'); B=nc.Dataset('CHD/croco_bry.nc')
def csf(sc,ts,tb):
    c=(1-np.cosh(ts*sc))/(np.cosh(ts)-1)
    return (np.exp(tb*c)-1)/(1-np.exp(-tb))
def z(h,N=32,ts=7,tb=2,hc=200):
    sc=(np.arange(1,N+1)-N-0.5)/N; cs=csf(sc,ts,tb)
    return (hc*sc[:,None,None]+cs[:,None,None]*h)/(hc+h)*h
lp,ap,hp=P['lon_rho'][:],P['lat_rho'][:],P['h'][:]
lc,ac,hcg=C['lon_rho'][:],C['lat_rho'][:],C['h'][:]
t=2  # record 3
zp=z(hp)
T=H['temp'][t]; S=H['salt'][t]; Z=H['zeta'][t]
U=H['u'][t]; V=H['v'][t]
Ur=np.concatenate([U[:,:,:1],0.5*(U[:,:,1:]+U[:,:,:-1]),U[:,:,-1:]],axis=2)
Vr=np.concatenate([V[:,:1],0.5*(V[:,1:]+V[:,:-1]),V[:,-1:]],axis=1)
pts=np.c_[lp.ravel(),ap.ravel()]
def hint(f2,xi,yi): return griddata(pts,f2.ravel(),(xi,yi),method='linear')
sl={'south':(slice(0,2),slice(None)),'north':(slice(-2,None),slice(None)),'east':(slice(None),slice(-2,None)),'west':(slice(None),slice(0,2))}
for b,(sj,si) in sl.items():
    x=lc[sj,si]; y=ac[sj,si]; zc=z(hcg[sj,si])
    def interp3(F):
        Fh=np.array([hint(F[k],x,y) for k in range(32)]); zh=np.array([hint(zp[k],x,y) for k in range(32)])
        out=np.zeros_like(zc)
        for idx in np.ndindex(x.shape):
            out[(slice(None),)+idx]=np.interp(zc[(slice(None),)+idx],zh[(slice(None),)+idx],Fh[(slice(None),)+idx])
        return out
    edge={'south':lambda a:a[...,0,:],'north':lambda a:a[...,-1,:],'east':lambda a:a[...,:,-1],'west':lambda a:a[...,:,0]}[b]
    for nm,F in [('temp',T),('salt',S)]:
        e=edge(interp3(F)); o=B[nm+'_'+b][t]  # (s, xi)
        print(f'{nm}_{b:5s} maxdiff {np.nanmax(abs(o-e)):.2e}  range {o.min():.3f}..{o.max():.3f}')
    ez=edge(hint(Z,x,y)); oz=B['zeta_'+b][t]; print(f'zeta_{b:5s} maxdiff {np.nanmax(abs(oz-ez)):.2e} max {abs(oz).max():.3f}')
    uc=interp3(Ur); vc=interp3(Vr)
    if b in('south','north'):
        u=0.5*(uc[:,:,1:]+uc[:,:,:-1]); v=0.5*(vc[:,1:,:]+vc[:,:-1,:])
        eu=edge(u); ev=v[:,0,:]
    else:
        u=0.5*(uc[:,:,1:]+uc[:,:,:-1]); v=0.5*(vc[:,1:,:]+vc[:,:-1,:])
        eu=u[:,:,0]; ev=edge(v)
    ou=B['u_'+b][t]; ov=B['v_'+b][t]
    print(f'u_{b:5s} maxdiff {np.nanmax(abs(ou-eu)):.2e} max {abs(ou).max():.3f} | v maxdiff {np.nanmax(abs(ov-ev)):.2e} max {abs(ov).max():.3f}')
print('bry_time',B['bry_time'][:])
