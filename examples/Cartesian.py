#!/usr/bin/env python

from mcrt3d import Params
from mcrt3d.grid import CartesianGrid
from mcrt3d.dust import Dust
from mcrt3d.sources import Star
from mcrt3d.camera import Image
from mcrt3d.constants.astronomy import M_sun, R_sun, AU
from mcrt3d.constants.physics import c
from numpy import array, arange, pi, zeros, logspace

# Set up the grid.

def SetupParams():
    Q = Params()

    Q.nphot = 100000
    Q.bw = True
    Q.scattering = False
    Q.verbose = False
    Q.use_mrw = False
    Q.mrw_gamma = 4

    return Q

def SetupGrid():
    # Set up the dust.

    dust = Dust(filename="dustkappa_yso.inp", radmc3d=True)

    # Set up the star.

    star = Star(0.0,0.0,0.0,M_sun,R_sun,4000.0)
    star.set_blackbody_spectrum(dust.nu)

    # Set up the grid.

    nx = 10
    ny = 10
    nz = 10

    x = (arange(nx)-(float(nx)-1)/2)*AU/1
    y = (arange(ny)-(float(ny)-1)/2)*AU/1
    z = (arange(nz)-(float(nz)-1)/2)*AU/1

    G = CartesianGrid(x,y,z)

    density = zeros((nx-1,ny-1,nz-1)) + 1.0e-17

    G.add_density(density, dust)

    G.add_source(star)

    return G

def SetupImages():
    nx = 256
    ny = 256
    pixel_size = AU/10

    x = (arange(nx,dtype=float)-float(nx)/2)*pixel_size
    y = (arange(ny,dtype=float)-float(ny)/2)*pixel_size

    nu = array([c / (1300. * 1.0e-4)])
    nnu = 1

    r = (3*4.5**2)**(1./2)*AU
    incl = pi/4
    pa = pi/4

    image = Image(r, incl, pa, x, y, nx, ny, nu, pixel_size, nnu)

    return array([image])

def SetupSpectra():
    nx = 1
    ny = 1
    pixel_size = 10*AU

    x = array([0.0])
    y = array([0.0])

    nu = c / (logspace(-1,4,1000) * 1.0e-4)
    nnu = 1000

    r = (3*4.5**2)**(1./2)*AU
    incl = 0
    pa = 0

    spectrum = Image(r, incl, pa, x, y, nx, ny, nu, pixel_size, nnu)

    return array([spectrum])
