# No shebang

"""
Collection of utilities for processing and plotting model output.
Ivan Lima - Fri Oct 20 19:26:51 EDT 2006
Last modified on Fri Feb 11 16:55:48 EST 2011
"""

# Note: No hardcoded user-dependent information

import numpy as N
import os, matplotlib
import matplotlib.pyplot as pl
from matplotlib import colors
from numpy import ma as MA

# seconds per day
spd = 60. * 60. * 24.

# short description of each case
case_descr = {\
    'ECO_T62gx3v5.22':'Physics Only', 'ECO_T62gx3v5.23':'Physics \& Dust',\
    'ECO_T62gx3v5.24':'Dust Only','ECO_T62gx3v5.22.pi':'Physics Only (PI)', \
    'ECO_T62gx3v5.23.pi':'Physics \& Dust (PI)'}

# create new colormaps

cdict1 = {'blue':  ((0.0, 0.75, 0.75), (0.25, 0.0, 0.0),
                   (0.5, 1.0, 1.0), (0.75, 0.0, 0.0), (1.0, 0.0, 0.0)),
          'green': ((0.0, 0.0, 0.0), (0.25, 0.75, 0.75),
                   (0.5, 1.0, 1.0), (0.75, 1.0, 1.0), (1.0, 0.0, 0.0)),
          'red'  : ((0.0, 0.0, 0.0), (0.25, 0.0, 0.0),
                   (0.5, 1.0, 1.0), (0.75, 1.0, 1.0), (1.0, 0.75, 0.75))}
BuGnWhYlRd = colors.LinearSegmentedColormap('BuGnWhYlRd',cdict1,256)

cdict2 = {'blue':  ((0.0, 1.0, 1.0), (0.25, 0.7, 0.7),
              (0.5, 1.0, 1.0), (0.75, 0.0, 0.0), (1.0, 0.0, 0.0)),
          'green': ((0.0, 1.0, 1.0), (0.25, 0.0, 0.0),
              (0.5, 1.0, 1.0), (0.75, 0.0, 0.0), (1.0, 1.0, 1.0)),
          'red'  : ((0.0, 0.0, 0.0), (0.25, 0.0, 0.0),
              (0.5, 1.0, 1.0), (0.75, 1.0, 1.0), (1.0, 1.0, 1.0))}
CyBuWhRdYl = colors.LinearSegmentedColormap('CyBuWhRdYl',cdict2,256)

cdict3 = {'blue':  ((0.0, 0.5, 0.5), (0.25, 1.0, 1.0),
              (0.5, 1.0, 1.0), (0.75, 0.0, 0.0), (1.0, 0.0, 0.0)),
          'green': ((0.0, 0.0, 0.0), (0.25, 0.0, 0.0),
              (0.5, 1.0, 1.0), (0.75, 0.0, 0.0), (1.0, 0.0, 0.0)),
          'red'  : ((0.0, 0.0, 0.0), (0.25, 0.0, 0.0),
              (0.5, 1.0, 1.0), (0.75, 1.0, 1.0), (1.0, 0.5, 0.5))}
BuWhRd = colors.LinearSegmentedColormap('BuWhRd',cdict3,256)

cdict4 = {'blue':  ((0.0, 1.0, 1.0), (0.25, 1.0, 1.0),
              (0.5, 0.0, 0.0), (0.75, 0.0, 0.0), (1.0, 0.0, 0.0)),
          'green': ((0.0, 1.0, 1.0), (0.25, 0.3, 0.3),
              (0.5, 0.7, 0.7), (0.75, 1.0, 1.0), (1.0, 0.0, 0.0)),
          'red'  : ((0.0, 1.0, 1.0), (0.25, 0.0, 0.0),
              (0.5, 0.0, 0.0), (0.75, 1.0, 1.0), (1.0, 1.0, 1.0))}
WhBuGrYlRd = colors.LinearSegmentedColormap('WhBuGrYlRd',cdict4,256)

def fix_pop_grid(tlon,tlat,data):
    """
    Pad coordinates and data on CCSM/POP gx3v5 grid so it can be
    plotted with matplotlib/basemap
    tlon,tlat,data must be 2D arrays

    Inputs:
        tlon, tlat, data

    Outputs:
        lon, lat, data

    """
    # make lon monotonic and pad coordinate and data arrays along lon axis
    tlon = N.where(N.greater_equal(tlon,tlon[:,0].min()),tlon-360,tlon)
    lon  = N.concatenate((tlon,tlon+360,tlon+2*360),1)
    lat  = N.concatenate((tlat,tlat,tlat),1)
    if hasattr(data,'mask'):
        data = MA.concatenate((data,data,data),-1)
    else:
        data = N.concatenate((data,data,data),-1)

    lon = lon - 360
    # clip grid - this allows to clip map anywhere between -360 and 360
    ind1 = N.searchsorted(lon[0,:],-360)
    ind2 = N.searchsorted(lon[0,:],360)
    lon  = lon[:,ind1-1:ind2+1]
    lat  = lat[:,ind1-1:ind2+1]
    data = data[...,ind1-1:ind2+1]

    return lon, lat, data

def fix_pop_grid_test(tlon,tlat,data):
    """
    Pad coordinates and data on CCSM/POP gx3v5 grid so it can be
    plotted with matplotlib/basemap
    tlon,tlat,data must be 2D arrays
    """
    # make lon monotonic and pad coordinate and data arrays along lon axis
    tlon = N.where(N.greater_equal(tlon,min(tlon[:,0])),tlon-360,tlon)
    lon  = N.concatenate((tlon,tlon+360),1)
    lat  = N.concatenate((tlat,tlat),1)
    if hasattr(data,'mask'):
        data = MA.concatenate((data,data),1)
    else:
        data = N.concatenate((data,data),1)

    return lon, lat, data

def top_labels(ax,left_string,center_string,right_string,fontsize=12):
    """
    Include labels/text strings on the top right and top
    left of the plot.

    """
    # left label
    ax.text(0, 1.04, left_string, horizontalalignment='left',
        verticalalignment='center', transform=ax.transAxes, fontsize=fontsize)
    # center label
    ax.text(0.5, 1.04, center_string, horizontalalignment='center',
        verticalalignment='center', transform=ax.transAxes, fontsize=fontsize)
    # right label
    ax.text(1, 1.04, right_string, horizontalalignment='right',
        verticalalignment='center', transform=ax.transAxes, fontsize=fontsize)

def bottom_labels(ax,left_string,center_string,right_string,fontsize=12):
    """
    Include labels/text strings on the bottom right and bottom
    left of the plot.

    """
    # left label
    ax.text(0, -0.04, left_string, horizontalalignment='left',
        verticalalignment='center', transform=ax.transAxes, fontsize=fontsize)
    # center label
    ax.text(0.5, -0.04, center_string, horizontalalignment='center',
        verticalalignment='center', transform=ax.transAxes, fontsize=fontsize)
    # right label
    ax.text(1, -0.04, right_string, horizontalalignment='right',
        verticalalignment='center', transform=ax.transAxes, fontsize=fontsize)

def color_ind_lin(clevels,refind):
    """
    Computes the lower and upper indices of the colormap so zero is white.
    Assumes the contour level scale is linear.
    clevels = contour levels.
    refind  = index of the middle point of the colormap (white).
    """
    low,high = clevels.min(),clevels.max()
    ref      = float(-max(N.abs(low),N.abs(high)))
    ind      = N.round((clevels-ref)/N.abs(ref) * refind)
    beg, end =  int(ind[0]), int(ind[-1])
    return beg, end

def center_color_scale(cs):
    """
    Centers figure colormap so contour level zero is white.
    cs   = contour plot/set to be modified.
    """
    cmap       = cs.get_cmap()
    imin, imax = color_ind_lin(cs.levels,cmap.N/2)
    newcmap    = colors.ListedColormap(cmap(range(imin,imax))[:,0:3])
    cs.set_cmap(newcmap)

def remove_bottom_right_borders(ax):
    """
    Remove bottom and right borders from XY plots.
    ax = axes holding XY plot
    """
    ax.spines['bottom'].set_color('none')
    ax.spines['right'].set_color('none')
    ax.xaxis.set_ticks_position('top')
    ax.yaxis.set_ticks_position('left')
    ax.xaxis.set_label_position('top')

def remove_top_right_borders(ax):
    """
    Remove top and right borders from XY plots.
    ax = axes holding XY plot
    """
    ax.spines['top'].set_color('none')
    ax.spines['right'].set_color('none')
    ax.xaxis.set_ticks_position('bottom')
    ax.yaxis.set_ticks_position('left')

def adjust_spines(ax):
    """
    Displace spines to create a range plot.
    ax = axes holding XY plot
    """
    for loc, spine in ax.spines.items():
        if loc in ['left','bottom']:
            spine.set_position(('outward',10)) # outward by 10 points

    # create tick marks at end of each axis
    #xmin = ax.lines[0].get_xdata().min()
    #xmax = ax.lines[0].get_xdata().max()
    #ax.set_xticks([xmin,xmax])

    # remove top & righ borders
    remove_top_right_borders(ax)

def adjust_spines_top(ax):
    """
    Displace spines to create a range plot preserving left and top axis.
    ax = axes holding XY plot
    """
    for loc, spine in ax.spines.items():
        if loc in ['left','top']:
            spine.set_position(('outward',10)) # outward by 10 points

    # create tick marks at end of each axis
    #xmin = ax.lines[0].get_xdata().min()
    #xmax = ax.lines[0].get_xdata().max()
    #ax.set_xticks([xmin,xmax])

    # remove bottom & righ borders
    remove_bottom_right_borders(ax)

def logcscale(vmin,vmax,num=15,decimals=3):
    """
    Create a log scale for contour plots.
    """
    cscale = N.concatenate((N.array([-vmin]),N.round(N.logspace(N.log(vmin),
        N.log(vmax),num=num,base=N.e),decimals=decimals)))
    return cscale

def lincscale(vmin,vmax,inc=1):
    """
    Create a linear scale for contour plots.
    """
    cscale = N.concatenate((N.array([-vmin]),N.arange(vmin,vmax,inc)))
    return cscale

def taylor_diagram(ax,R,std,legends,title,lgfontsize=10,tlfontsize=15,
        lgon=True,rlabel=1.045):
    """
    Creates a Taylor Diagram with the statistics R and std.
    R          : correlation coefficients
    std        : normalized standard deviations
    legends    : legends for each point
    title      : plot title
    lgfontsize : font size for plot legends
    tlfontsize : font size for plot title
    lgon       : include legends (boolean)
    rlabel     : radius for azimuthal axis labels

    (NOTE: need to find a way to set rlabel automaticaly)
    """
    if R.shape != std.shape:
        print('R and std have different shapes. Check your data.')
        os.sys.exit()

    markers = ['.','o','v','^','<','>','s','p','*',
               'h','H','+','x','D','d'] * 2
    colors  = ['b','g','r','c','m','y','k'] * 4
    pl.rc('legend',fontsize=lgfontsize)

    # coordinates for correlation/azimuthal axis
    rmin, rmax = 0, 1
    theta = N.arange(0,91)*N.pi/180. # angles for correlation/azimuthal axis
    r = rmax - rmin
    x = r * N.cos(theta) + rmin
    y = r * N.sin(theta) + rmin

    # create correlation/azimuthal axis
    curve = matplotlib.lines.Line2D(x,y,transform=ax.transAxes,
            color='black',axes=ax)
    ax.add_line(curve)

    # remove top and right axis from plot
    ax.spines['top'].set_color('none')
    ax.spines['right'].set_color('none')
    ax.xaxis.set_ticks_position('bottom')
    ax.yaxis.set_ticks_position('left')

    ax.set_aspect('equal')

    rscale = 0.99 # smaller radius for drawing tick marks

    # major tick marks and labels
    Rmajor   = N.array([0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,0.95,0.99])
    angC_deg = N.rad2deg(N.arccos(Rmajor))
    xC       = N.cos(N.deg2rad(angC_deg)) * rlabel
    yC       = N.sin(N.deg2rad(angC_deg)) * rlabel
    for i in range(len(Rmajor)):
        xtm = [N.cos(N.deg2rad(angC_deg[i])),
                    rscale * N.cos(N.deg2rad(angC_deg[i]))]
        ytm = [N.sin(N.deg2rad(angC_deg[i])),
                    rscale * N.sin(N.deg2rad(angC_deg[i]))]
        line = matplotlib.lines.Line2D(xtm,ytm,color='black',
                transform=ax.transAxes)
        ax.add_line(line)
        ax.text(xC[i],yC[i],Rmajor[i],rotation=angC_deg[i],
                transform=ax.transAxes,horizontalalignment='center',
                verticalalignment='center')

    # minor tick marks and labels
    Rminor = [0.05,0.15,0.25,0.35,0.45,0.55,0.65,0.75,0.85,0.91,\
                0.92,0.93,0.94,0.96,0.97,0.98]
    angC_deg = N.rad2deg(N.arccos(Rminor))
    xC       = N.cos(N.deg2rad(angC_deg)) * (1.01)
    yC       = N.sin(N.deg2rad(angC_deg)) * (1.01)
    for i in range(len(Rminor)):
        xtm = [N.cos(N.deg2rad(angC_deg[i])),
                    rscale * N.cos(N.deg2rad(angC_deg[i]))]
        ytm = [N.sin(N.deg2rad(angC_deg[i])),
                    rscale * N.sin(N.deg2rad(angC_deg[i]))]
        line = matplotlib.lines.Line2D(xtm,ytm,color='black',
                transform=ax.transAxes)
        ax.add_line(line)

    # label for correlation/azimuthal axis
    xx = N.cos(N.pi/4)
    ax.text(xx,xx,'Correlation',rotation=-45,transform=ax.transAxes)

    # X and Y axis label
    ax.set_ylabel('Normalized Standard Deviation')
    ax.set_xlabel('Normalized Standard Deviation')
    #ax.set_ylabel(r'$\displaystyle\frac{\sigma_{mod}}{\sigma_{obs}}$')
    #ax.set_xlabel(r'$\displaystyle\frac{\sigma_{mod}}{\sigma_{obs}}$')

    # plot statistics
    for n in range(len(std)):
        alpha = N.arccos(R[n])
        x     = std[n] * N.cos(alpha)
        y     = std[n] * N.sin(alpha)
        m,    = ax.plot(x,y,colors[n]+markers[n],label=legends[n])
        m.set_mec(colors[n])

    # add legends
    if lgon:
        ax.legend(loc='upper left',bbox_to_anchor=(0.95,1.05),numpoints=1)

    # add title
    ax.text(0.5,1.1,title,transform=ax.transAxes,horizontalalignment='center',
            verticalalignment='bottom',fontsize=tlfontsize)

    # set X axis and Y axis limits to be the same
    xydata = N.arange(0,100.5,0.5)
    n = N.searchsorted(xydata,std.max())
    xymin, xymax = 0, max(1,xydata[n])
    #xymin, xymax = 0, N.ceil(std.max()*10)/10
    #xymin, xymax = 0, N.ceil(std.max())
    ax.set_xlim((xymin,xymax))
    ax.set_ylim((xymin,xymax))

    # set tick marks & labels
    if xymax <= 1:
        s = N.arange(0,1.25,0.25)
        ax.set_xticks(s)
        ax.set_yticks(s)
        ax.set_xticklabels(s)
        ax.set_yticklabels(s)
    else:
        ax.set_xticks(xydata[:n+1])
        ax.set_yticks(xydata[:n+1])
        ax.set_xticklabels(xydata[:n+1])
        ax.set_yticklabels(xydata[:n+1])

    # add lines of constant std
    for r in ax.get_yticks()[1:-1]:
        x = r * N.cos(theta) + rmin
        y = r * N.sin(theta) + rmin
        line = matplotlib.lines.Line2D(x,y,transform=ax.transData,
                color='black',lw=0.5,axes=ax,linestyle='--')
        ax.add_line(line)

def addcyclic(data):
	"""
	Adds cyclic points to an array in rightmost dimension.
	data = input 2D array.
	"""
	if data.ndim != 2:
		print('ERROR: Input array is not two-dimensional')
		return

	if MA.isMA(data):
		newdata = MA.concatenate((data,data[:,0,N.newaxis]),axis=-1)
	else:
		newdata = N.concatenate((data,data[:,0,N.newaxis]),axis=-1)

	return newdata
