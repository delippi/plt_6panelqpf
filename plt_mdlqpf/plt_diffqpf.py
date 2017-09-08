#!/usr/bin/python

import pygrib
import numpy as np
import matplotlib
import ncepy
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap, cm
import time
#import colormap
import sys 

if __name__ == '__main__':


  t1a = time.clock()
  print("Starting...plt_mdl.py...")

#  grbs = pygrib.open('/scratch2/portfolios/NCEPDEV/meso/noscrub/Jacob.Carley/POWER/RETRO/nwpower_retro_fcst_AugCTL/namrr.2004080912/namrr.t12z.conusnest.hiresf06.tm00')  
  
  # Read forecast valid time grib file from command line
  valpdy=sys.argv[1]  
  valcyc=sys.argv[2]
  domid=str(sys.argv[3])
  name=str(sys.argv[4])
  hr=int(sys.argv[5])
  maxhr=sys.argv[6]
  clOBS=sys.argv[7].split(","); clevsOBS = [float(i) for i in clOBS]
  OB_lines=sys.argv[8]; OB_lines=(True if OB_lines == '.true.' else False)
  #OB_lines=False #no need for these here...
  num=int(maxhr)/3
  gribfile = ["" for x in range(num)]
  grbs     = ["" for x in range(num)]
  obsfile  = ["" for x in range(num)]
  obs      = ["" for x in range(num)]
  cyctime  = ["" for x in range(num)]
  grbtime  = ["" for x in range(num)]
  date     = ["" for x in range(num)]
  fhr      = ["" for x in range(num)]
  for i in range(num):
      gribfile[i]=sys.argv[i+9]
      grbs[i]=pygrib.open(gribfile[i])
      obsfile[i]=sys.argv[i+num+9]
      obs[i]=pygrib.open(obsfile[i])       
      bucket_length=3 
    
      # Get the lats and lons
      lats, lons = grbs[i][1].latlons()
      latsOBS, lonsOBS = obs[i][1].latlons()
  
      #Get the date/time and forecast hour
      fhr[i]=grbs[i][1]['stepRange'] # Forecast hour
      # Pad fhr with a 0
      if int(fhr[i]) < 10:
        fhr[i]='0'+fhr[i]
      cyctime[i]=grbs[i][1].dataTime #Cycle (e.g. 1200 UTC)
 
      if fhr[i]==0: cyctime[i]=cytime[i]+'00' 
      #Pad with a zero and convert to a string
      if cyctime[i] < 1000:
        grbtime[i]='0'+repr(cyctime[i])
      else:
        grbtime[i]=repr(cyctime[i]) 
  
      date[i]=grbs[i][1].dataDate    #PDY


  # Specify some plotting domains which have the regions pre-set in ncepy
#  domains=['CONUS','NW','NC','NE','SW','SC','SE','Great_Lakes']
  domains=['SC4']
  proj='lcc'
  llcrnrlon_sc,llcrnrlat_sc,urcrnrlon_sc,urcrnrlat_sc,res=ncepy.corners_res('SC',proj=proj)

  # Start reading fields to be plotted


  # read precip
  precip        = ["" for x in range(num)]
  precip_vals   = ["" for x in range(num)]
  precipOBS     = ["" for x in range(num)]
  precipOBSvals = ["" for x in range(num)]
  bucket_length=3

  for i in range(num):
      precip[i] = grbs[i].select(name='Total Precipitation',lengthOfTimeRange=3)[0] # QPF is stored as mm 
      precipOBS[i] = obs[i].select(name='Total Precipitation')[0] # QPF is stored as mm 
      #Now get the values from this msg
      precip_vals[i] = precip[i].values/25.4
      precipOBSvals[i] = precipOBS[i].values/25.4
      if(i>0):
          precip_vals[i] = precip_vals[i] + precip_vals[i-1]
          precipOBSvals[i] = precipOBSvals[i] + precipOBSvals[i-1]
      if(i == num-1):
          precip_vals=precip_vals[i]
          precipOBSvals=precipOBSvals[i]

  diff=precip_vals-precipOBSvals
  t2a=time.clock()
  t3a=round(t2a-t1a, 3)
  print(repr(t3a)+" seconds to read all gribs msgs!")

  ###################################################
  #       START PLOTTING FOR EACH DOMAIN            #
  ###################################################
 
  #Use gempak color table for precipitation    
  gemlist=ncepy.gem_color_list()
  # Use gempak fline color levels from pcp verif page
  #pcplist=[23,22,21,20,19,10,17,16,15,14,29,28,24,25]
  #Extract these colors to a new list for plotting
  #pcolors=[gemlist[i] for i in pcplist]
#  clevspos =[0.01,0.05,0.1,0.25,0.5,0.75,1.,1.5,2.,3.,4.]
#  pcplist  =[  23,  22, 21,  20, 19,  10,17, 16,15,14,29]
#  pcolorspos=[gemlist[i] for i in pcplist]
#  clevsneg =[-4.,-3.,-2.,-1.5,-1.,-0.75,-0.5,-0.25,-0.1,-0.05,-0.01]
#  pcplist  =[ 31,    7, 12, 14,  30, 29,   28,  27,   26,  25,   24]
#  pcolorsneg=[gemlist[i] for i in pcplist]
     

  for dom in domains:
    t1dom=time.clock()
    print('Working on '+dom)

    # create figure and axes instances
    fig = plt.figure(figsize=(11,11))
    ax = fig.add_axes([0.1,0.1,0.8,0.8])
    
    # create LCC basemap instance and set the dimensions
    #llcrnrlon,llcrnrlat,urcrnrlon,urcrnrlat,res=ncepy.corners_res(dom)    
    if(dom == 'SC1'):
       llcrnrlon,llcrnrlat,urcrnrlon,urcrnrlat=-101.0,29.0,-94.0,33.0
    if(dom == 'SC2'):
       llcrnrlon,llcrnrlat,urcrnrlon,urcrnrlat=-98.0,29.5,-95.0,31.5
    if(dom == 'SC3'):
       llcrnrlon,llcrnrlat,urcrnrlon,urcrnrlat=-99.38,29.25,-95.38,32.18
    if(dom == 'SC4'):
       llcrnrlon,llcrnrlat,urcrnrlon,urcrnrlat=-104.0,28.0,-92.0,35.0
       #llcrnrlon,llcrnrlat,urcrnrlon,urcrnrlat=-102.0,26.0,-92.0,33.0
                                              #-109.0, 25.0, -83.0, 38.0, 'l'
    Lon0=262.5 #grbs[1]['LoVInDegrees']
    Lat0=38.5  #grbs[1]['LaDInDegrees']
    Lat1=38.5  #grbs[1]['Latin1InDegrees'] 
    Lat2=38.5  #grbs[1]['Latin2InDegrees']
    gribproj=grbs[0][1]['gridType']
    #rearth=grbs[1]['radius']
    rearth=6371229
    m = Basemap(llcrnrlon=llcrnrlon,llcrnrlat=llcrnrlat,urcrnrlon=urcrnrlon,urcrnrlat=urcrnrlat,\
   	      #rsphere=(6378137.00,6356752.3142),\
   	      rsphere=rearth,\
   	      resolution=res,projection='lcc',\
   	      #lat_1=25.0,lon_0=-95.0,ax=ax)
   	      #lat_1=30.0,lon_0=-100.0,ax=ax)
   	      lat_1=Lat1,lat_2=Lat2,lat_0=Lat0,lon_0=Lon0,ax=ax)

    #parallels = np.arange(-80.,90,10.)
    parallels = np.arange(30.,90,2.)
    meridians = np.arange(0.,360.,2.)
    m.drawmapboundary(fill_color='#7777ff')
    m.fillcontinents(color='#ddaa66', lake_color='#7777ff', zorder = 0)
    m.drawcoastlines(linewidth=1.25)
    m.drawstates(linewidth=1.25)
    m.drawcountries(linewidth=1.25)
    m.drawparallels(parallels,labels=[1,0,0,1])
    m.drawmeridians(meridians,labels=[1,0,0,1])

    t1=time.clock()
    print('Working on '+str(maxhr)+'hr pcp for '+dom) 
    
    if dom != 'CONUS':  
      # Draw the the counties if not CONUS
      # Note that drawing the counties can slow things down!
      m.drawcounties(linewidth=0.2, color='k')
      skip=25
    else:
      skip=45
    
    #  Map/figure has been set up here (bulk of the work), save axes instances for
    #     use again later   
    keep_ax_lst = ax.get_children()[:]


    #Now plot REFC dBZ
    # Set contour levels for precip    
    #  clevs = [0,0.1,2,5,10,15,20,25,35,50,75,100,125,150,175]  #mm
    #clevs   =[0.01,0.05,0.1,0.25,0.5,0.75,1.,1.5,2.,3.,4.,5.,6.,7.] #inches
    #clevsOBS=[0.75,4.]
    #Now plot the precip
    #Use gempak color table for precipitation    
    gemlist=ncepy.gem_color_list()
    make_diff_plot1=False
    make_diff_plot2=True 
    if(make_diff_plot1):
      gemlist=ncepy.gem_color_list()
      clevspos =[0.01,0.05,0.1,0.25,0.5,0.75,1.,1.5,2.,3.,4.]
      pcplist  =[  23,  22, 21,  20, 19,  10,17, 16,15,14,29]
      pcolorspos=[gemlist[i] for i in pcplist]
      clevsneg =[-4.,-3.,-2.,-1.5,-1.,-0.75,-0.5,-0.25,-0.1,-0.05,-0.01]
      pcplist  =[ 31, 7,  12,  14, 30,   29,  28,   27,  26,   25,   24]
      pcolorsneg=[gemlist[i] for i in pcplist]
      cspos = m.contourf(lons,lats,diff,clevspos,latlon=True,colors=pcolorspos,extend='max')
      csneg = m.contourf(lons,lats,diff,clevsneg,latlon=True,colors=pcolorsneg,extend='min')
      cbarpos = m.colorbar(cspos,location='bottom',pad="25%",ticks=clevspos)#,format='%.2f')
      cbarneg = m.colorbar(csneg,location='bottom',pad="5%",ticks=clevsneg)#,format='%.2f')
      cbarpos.ax.tick_params(labelsize=8.5)
      cbarneg.ax.tick_params(labelsize=8.5)
      cbarpos.set_label('inches')

    if(make_diff_plot2):
      cmap = plt.get_cmap(name='RdBu_r')
      #cmap = colormap.diff_colormap(clevs)
      #clevs = [-4.,-3.,-2.,-1.5,-1.,-0.75,-0.5,-0.25,-0.1,-0.05,-0.01,0.00,0.01,0.05,0.1,0.25,0.5,0.75,1.,1.5,2.,3.,4.]
      clevs = [-4.,-3.,-2.,-1.5,-1.,-0.75,-0.5,-0.25,-0.1,-0.05,0.05,0.1,0.25,0.5,0.75,1.,1.5,2.,3.,4.]
      cs = m.contourf(lons,lats,diff,clevs,latlon=True,cmap=cmap,linewidths=4.0,extend='both')
      cbar = m.colorbar(cs,location='bottom',pad="5%",ticks=clevs)
      #cbar.ax.set_xticklabels(clevs,rotation=90)
      cbar.ax.tick_params(labelsize=8.5)

    if(OB_lines): 
      cs2=m.contour(lonsOBS,latsOBS,precipOBSvals,clevsOBS,colors='black',latlon=True,linewidths=4.0) 
      plt.clabel(cs2, fontsize=11, inline=1)

    plt.title(name+' CONUSNEST '+str(maxhr).zfill(2)+' Hr QPF Difference at F'+str(hr)+' \n'+\
              repr(date[0])+' '+grbtime[0]+'Z cycle Valid '+valpdy+' '+valcyc+\
              '00Z',fontsize='18',weight='bold')
    outfile='./'+str(maxhr)+'hrpcp_'+dom+'_'+domid+'_'+repr(date[-1])+grbtime[-1]+'v'+str(valpdy)+\
                str(valcyc)+'.png'
    print(outfile)
    plt.savefig(outfile,bbox_inches='tight')
    t2 = time.clock()
    t3=round(t2-t1, 3)
    print(repr(t3)+" seconds to plot precip: "+dom)

  
