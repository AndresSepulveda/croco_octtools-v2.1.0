# Verifica el orden de dimensiones (…, eta, xi) y valores anómalos en los
# archivos generados en CROCO_FILES/.  Uso:  python3 check_outputs.py CROCO_FILES
import sys, glob, numpy as np, netCDF4 as nc
d = sys.argv[1] if len(sys.argv) > 1 else 'CROCO_FILES'
bad = 0
for fn in sorted(glob.glob(d + '/*.nc')):
    f = nc.Dataset(fn); f.set_auto_mask(False); issues = []
    for v in f.variables.values():
        dims = v.dimensions
        xi = [i for i, x in enumerate(dims) if x.startswith('xi_')]
        eta = [i for i, x in enumerate(dims) if x.startswith('eta_')]
        if xi and eta and not (eta[0] == len(dims) - 2 and xi[0] == len(dims) - 1):
            issues.append(v.name + ' dims ' + str(dims))
        if v.dtype.kind == 'f':
            a = v[:]
            if np.isnan(a).any():
                issues.append(v.name + ' NaN')
    print(('OK   ' if not issues else 'FAIL ') + fn, issues[:5]); bad += len(issues)
print('issues:', bad)
