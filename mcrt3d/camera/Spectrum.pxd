import cython

import numpy
cimport numpy

from ..mcrt3d cimport Spectrum

cdef class SpectrumObj:
    cdef Spectrum *obj
    cdef int nnu, nlam
    cdef double r, incl, pa, pixel_size
    cdef numpy.ndarray nu, lam, intensity
