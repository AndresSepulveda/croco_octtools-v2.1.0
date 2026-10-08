#!/usr/bin/env python3
"""
Synthetic CROCO history file (croco_his.nc) for testing the
visualization tools (oct_croco_gui, oct_horizslice, oct_vertslice ...).

Usage: python3 gen_test_his.py CROCO_FILES/croco_grd.nc CROCO_FILES/croco_ini.nc CROCO_FILES/croco_his.nc

Structure copied from a CROCO output file: grid variables, s-coordinate
parameters (as variables AND global attributes), scrum_time/time,
zeta, ubar, vbar, u, v, w, temp, salt, AKt, hbl. The ini file gives the
initial temp/salt; an anticyclonic eddy drifting westward is added to
temperature, zeta and velocities (decreasing with depth).
"""
import sys
import numpy as np
import netCDF4 as nc

grd, ini, out = sys.argv[1:4]
G = nc.Dataset(grd)
I = nc.Dataset(ini)
lon = G['lon_rho'][:]; lat = G['lat_rho'][:]
h = G['h'][:]; mask = G['mask_rho'][:]
M, L = h.shape
N = len(I.dimensions['s_rho'])
theta_s = float(I['theta_s'][0]); theta_b = float(I['theta_b'][0])
hc = float(I['hc'][0]); vtr = int(I['Vtransform'][0])
NT = 6
dt = 5 * 86400.


def csf(sc):
    if theta_s > 0:
        c = (1 - np.cosh(theta_s * sc)) / (np.cosh(theta_s) - 1)
    else:
        c = -sc ** 2
    if theta_b > 0:
        c = (np.exp(theta_b * c) - 1) / (1 - np.exp(-theta_b))
    return c


sc_r = (np.arange(1, N + 1) - N - 0.5) / N
sc_w = (np.arange(0, N + 1) - N) / N
Cs_r = csf(sc_r); Cs_w = csf(sc_w)


def zlev(zeta, sc, cs):
    z0 = (hc * sc[:, None, None] + cs[:, None, None] * h) / (hc + h)
    return zeta + (zeta + h) * z0


o = nc.Dataset(out, 'w', format='NETCDF3_64BIT_OFFSET')
for d, n in [('xi_rho', L), ('xi_u', L - 1), ('eta_rho', M), ('eta_v', M - 1),
             ('s_rho', N), ('s_w', N + 1), ('time', None), ('one', 1)]:
    o.createDimension(d, n)
o.title = 'Synthetic CROCO history file (tests)'
o.type = 'CROCO history file'
o.theta_s = theta_s; o.theta_b = theta_b; o.hc = hc; o.Tcline = hc
o.VertCoordType = 'NEW' if vtr == 2 else 'OLD'


def var(name, dims, data=None, ln='', units='', typ='f8'):
    v = o.createVariable(name, typ, dims)
    if ln: v.long_name = ln
    if units: v.units = units
    if data is not None: v[:] = data
    return v


sph = o.createVariable('spherical', 'S1', ('one',)); sph[:] = np.array(['T'], 'S1')
var('Vtransform', ('one',), vtr, 'vertical terrain-following transformation equation', typ='i4')
var('theta_s', ('one',), theta_s); var('theta_b', ('one',), theta_b)
var('hc', ('one',), hc, 'S-coordinate parameter, critical depth', 'meter')
var('sc_r', ('s_rho',), sc_r); var('sc_w', ('s_w',), sc_w)
var('s_rho', ('s_rho',), sc_r); var('s_w', ('s_w',), sc_w)
var('Cs_r', ('s_rho',), Cs_r); var('Cs_w', ('s_w',), Cs_w)
for n in ['h', 'f', 'pm', 'pn', 'lon_rho', 'lat_rho', 'lon_u', 'lat_u', 'lon_v',
          'lat_v', 'angle', 'mask_rho', 'mask_u', 'mask_v', 'mask_psi']:
    if n in G.variables:
        s = G[n]
        dims = tuple(s.dimensions)
        dims = tuple({'eta_u': 'eta_rho', 'xi_v': 'xi_rho', 'eta_psi': 'eta_v',
                      'xi_psi': 'xi_u'}.get(d, d) for d in dims)
        var(n, dims, s[:], getattr(s, 'long_name', ''), getattr(s, 'units', ''))
var('scrum_time', ('time',), None, 'time since initialization', 'second')
var('time', ('time',), None, 'time since initialization', 'second')
var('zeta', ('time', 'eta_rho', 'xi_rho'), None, 'free-surface', 'meter')
var('ubar', ('time', 'eta_rho', 'xi_u'), None, 'vertically integrated u-momentum component', 'meter second-1')
var('vbar', ('time', 'eta_v', 'xi_rho'), None, 'vertically integrated v-momentum component', 'meter second-1')
var('u', ('time', 's_rho', 'eta_rho', 'xi_u'), None, 'u-momentum component', 'meter second-1')
var('v', ('time', 's_rho', 'eta_v', 'xi_rho'), None, 'v-momentum component', 'meter second-1')
var('w', ('time', 's_rho', 'eta_rho', 'xi_rho'), None, 'vertical momentum component', 'meter second-1')
var('temp', ('time', 's_rho', 'eta_rho', 'xi_rho'), None, 'potential temperature', 'Celsius')
var('salt', ('time', 's_rho', 'eta_rho', 'xi_rho'), None, 'salinity', 'PSU')
var('AKt', ('time', 's_w', 'eta_rho', 'xi_rho'), None, 'temperature vertical diffusion coefficient', 'meter2 second-1')
var('hbl', ('time', 'eta_rho', 'xi_rho'), None, 'depth of planetary boundary layer', 'meter')

T0 = I['temp'][0]; S0 = I['salt'][0]
lon0, lat0 = lon.mean(), lat.mean()
R = 1.5  # eddy radius (deg)
m = mask.astype(bool)
for t in range(NT):
    time = (t + 1) * dt
    ce = lon0 + 2 - 0.5 * t          # westward drift
    r2 = ((lon - ce) ** 2 + (lat - lat0) ** 2) / R ** 2
    g = np.exp(-r2)
    zeta = 0.3 * g * m
    z = zlev(zeta, sc_r, Cs_r)
    decay = np.exp(z / 400.)
    temp = T0 + 3 * g * decay
    salt = S0 + 0.2 * g * decay
    # anticyclonic (southern hemisphere: counter-clockwise) geostrophic-like flow
    dx = (lon - ce); dy = (lat - lat0)
    us = -0.8 * dy / R * g; vs = 0.8 * dx / R * g
    u3 = us * decay; v3 = vs * decay
    u3 = 0.5 * (u3[:, :, 1:] + u3[:, :, :-1]); v3 = 0.5 * (v3[:, 1:, :] + v3[:, :-1, :])
    mu = m[:, 1:] & m[:, :-1]; mv = m[1:, :] & m[:-1, :]
    u3 *= mu; v3 *= mv
    Hz = np.diff(zlev(zeta, sc_w, Cs_w), axis=0)
    D = Hz.sum(0)
    ub = (u3 * 0.5 * (Hz[:, :, 1:] + Hz[:, :, :-1])).sum(0) / (0.5 * (D[:, 1:] + D[:, :-1]))
    vb = (v3 * 0.5 * (Hz[:, 1:, :] + Hz[:, :-1, :])).sum(0) / (0.5 * (D[1:, :] + D[:-1, :]))
    o['scrum_time'][t] = time; o['time'][t] = time
    o['zeta'][t] = zeta
    o['u'][t] = u3; o['v'][t] = v3; o['ubar'][t] = ub; o['vbar'][t] = vb
    o['w'][t] = 1e-4 * g * decay * m
    o['temp'][t] = temp; o['salt'][t] = salt
    o['AKt'][t] = 1e-3 * np.ones((N + 1, M, L))
    o['hbl'][t] = 30 + 20 * g
o.close()
print('written', out)
