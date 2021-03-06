import cython

import numpy
cimport numpy

from ..constants.physics import sigma
from .. import misc
import scipy.integrate
import h5py

from ..mcrt3d cimport Source, Star

cdef class StarObj:
    def __init__(self, double x=0., double y=0., double z=0., \
            double mass=0., double radius=0., double temperature=0., \
            filename=None):

        if filename != None:
            self.read(filename)
        else:
            self.set_parameters(x, y, z, mass, radius, temperature)

        self.obj = new Star(x, y, z, mass, radius, temperature)

    def __del__(self):
        del self.obj

    def set_parameters(self, double x, double y, double z, double mass, \
            double radius, double temperature):
        self.x = x
        self.y = y
        self.z = z
        self.mass = mass
        self.radius = radius
        self.temperature = temperature
        self.luminosity = 4*numpy.pi*radius**2 * sigma*temperature**4

    def set_blackbody_spectrum(self,numpy.ndarray[double, ndim=1, mode="c"] nu):
        self.nnu = nu.size
        self.nu = nu
        self.Bnu = misc.B_nu(nu, self.temperature)
        self.luminosity = 4*numpy.pi*self.radius**2*sigma*self.temperature**4

        self.random_nu_CPD = scipy.integrate.cumtrapz(self.Bnu, x=nu, \
                initial=0) / numpy.trapz(self.Bnu, x=nu)

        cdef numpy.ndarray[double, ndim=1, mode="c"] Bnu = self.Bnu, \
                random_nu_CPD = self.random_nu_CPD

        self.obj.set_blackbody_spectrum(self.nnu, &nu[0], &Bnu[0], \
                self.luminosity, &random_nu_CPD[0])

    def read(self, filename=None, usefile=None):
        if (usefile == None):
            f = h5py.File(filename, "r")
        else:
            f = usefile

        self.mass = f['mass'].value
        self.luminosity = f['luminosity'].value
        self.temperature = f['temperature'].value
        self.radius = f['radius'].value
        self.x = f['x'].value
        self.y = f['y'].value
        self.z = f['z'].value

        if (usefile == None):
            f.close()

    def write(self, filename=None, usefile=None):
        if (usefile == None):
            f = h5py.File(filename, "w")
        else:
            f = usefile

        f['mass'] = self.mass
        f['luminosity'] = self.luminosity
        f['temperature'] = self.temperature
        f['radius'] = self.radius

        f['x'] = self.x
        f['y'] = self.y
        f['z'] = self.z

        if (usefile == None):
            f.close()
