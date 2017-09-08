
import pygrib
import numpy as np
import matplotlib
#matplotlib.use('Agg')   #Necessary to generate figs when not running an Xserver (e.g. via PBS)
import ncepy
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap, cm
import time
import sys 

if __name__ == '__main__':


  t1a = time.clock()
  print("Starting...plt_obs.py...")

#  grbs = pygrib.open('/scratch2/portfolios/NCEPDEV/meso/noscrub/Jacob.Carley/POWER/RETRO/nwpower_retro_fcst_AugCTL/namrr.2004080912/namrr.t12z.conusnest.hiresf06.tm00')  
  
  # Read forecast valid time grib file from command line
  valpdy=sys.argv[1]  
  valcyc=sys.argv[2]
  domid=sys.argv[3]
  numgribneeded=int(sys.argv[4])
  clOBS=sys.argv[5].split(","); clevsOBS = [float(i) for i in clOBS]
  OB_lines=sys.argv[6]; OB_lines=(True if OB_lines == '.true.' else False)
  gribfile = ["" for x in range(numgribneeded)]
  grbs     = ["" for x in range(numgribneeded)]
  cyctime  = ["" for x in range(numgribneeded)]
  date     = ["" for x in range(numgribneeded)]
  grbtime  = ["" for x in range(numgribneeded)]
  for i in range(numgribneeded):
      gribfile[i]=sys.argv[i+7]
      grbs[i]=pygrib.open(gribfile[i])

     # Get the lats and lons
      lats, lons = grbs[i][1].latlons()
      #Get the date/time and forecast hour
      fhr=grbs[i][1]['stepRange'] # Forecast hour

      cyctime[i]=grbs[i][1].dataTime #Cycle (e.g. 1200 UTC)
 
      if fhr==0: cyctime[i]=cytime[i]+'00' 
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


  # read apcp mm
  qpf_msgs = ["" for x in range(numgribneeded)]  
  qpf      = ["" for x in range(numgribneeded)]  
  for i in range(numgribneeded):
      qpf_msgs[i] = grbs[i].select(name='Total Precipitation')[0] # This is actually APCP mm
      #Now get the values from this msg
      qpf[i] = qpf_msgs[i].values
      qpf[i] = 0.0393701*qpf[i] #convert to inches - (1mm = 0.0393701 inches)
      if(i > 0):
          qpf[i]=qpf[i] + qpf[i-1]
      if(i == numgribneeded -1):
          qpf=qpf[i]

  t2a=time.clock()
  t3a=round(t2a-t1a, 3)
  print(repr(t3a)+" seconds to read all gribs msgs!")
  ###################################################
  #       START PLOTTING FOR EACH DOMAIN            #
  ###################################################

  for dom in domains:
    
    t1dom=time.clock()
    print('Working on '+dom)

    # create figure and axes instances
    fig = plt.figure(figsize=(11,11))
    ax = fig.add_axes([0.1,0.1,0.8,0.8])
    
    # create LCC basemap instance and set the dimensions
    llcrnrlon,llcrnrlat,urcrnrlon,urcrnrlat,res=ncepy.corners_res(dom)    
    if(dom == 'SC1'):
       llcrnrlon,llcrnrlat,urcrnrlon,urcrnrlat=-101.0,29.0,-94.0,33.0
    if(dom == 'SC2'):
       llcrnrlon,llcrnrlat,urcrnrlon,urcrnrlat=-98.0,29.5,-95.0,31.5
    if(dom == 'SC3'):
       llcrnrlon,llcrnrlat,urcrnrlon,urcrnrlat=-99.38,29.25,-95.38,32.18
    if(dom == 'SC4'):
       llcrnrlon,llcrnrlat,urcrnrlon,urcrnrlat=-104.0,28.0,-92.0,35.0
       #llcrnrlon,llcrnrlat,urcrnrlon,urcrnrlat=-102.0,26.0,-92.0,33.0

    m = Basemap(llcrnrlon=llcrnrlon,llcrnrlat=llcrnrlat,urcrnrlon=urcrnrlon,urcrnrlat=urcrnrlat,\
   	      rsphere=(6378137.00,6356752.3142),\
   	      resolution=res,projection='lcc',\
   	      lat_1=25.0,lon_0=-95.0,ax=ax)

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
    print('Working on QPF for '+dom) 
    
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


    #Now plot APCP
    #  clevs = [0,0.1,2,5,10,15,20,25,35,50,75,100,125,150,175]  #mm
    clevs    =[0.01,0.05,0.1,0.25,0.5,0.75,1.,1.5,2.,3.,4.,5.,6.,7.] #inches
    #clevsOBS =[0.75,4.] #inches
    #mycmap = ncepy.mrms_radarmap()
    gemlist = ncepy.gem_color_list()
    pcplist=[23,22,21,20,19,10,17,16,15,14,29,28,24,25]
    pcolors=[gemlist[i] for i in pcplist]
    
    cs = m.contourf(lons,lats,qpf,clevs,colors=pcolors,latlon=True,extend='max')
    if(OB_lines): m.contour(lons,lats,qpf,clevsOBS,colors='black',latlon=True,linewidths=4.0)
    cs.set_clim(5,75) 
    cbar = m.colorbar(cs,location='bottom',pad="5%",ticks=clevs)
    cbar.ax.tick_params(labelsize=8.5) 
    cbar.set_label('inches')
    #plt.title(domid+' 24-hr Total Precipitation \n'+repr(date)+' '+grbtime+'Z Valid '+\
    #          repr(date+1)+' '+grbtime+'Z')
    hh=numgribneeded*3
    num=numgribneeded-1
    #####################################################################################   
    plt.title(domid+' '+str(hh).zfill(2)+'-hr Total Precipitation \n'+repr(date[0])+' '+grbtime[0]+\
              'Z Valid '+repr(date[num])+' '+str(int(grbtime[num])+300)+'Z',fontsize='18',weight='bold')
    #####################################################################################   
    figname='./'+str(hh).zfill(2)+'hrpcp_'+dom+'_'+domid+'_'+str(valpdy)+str(valcyc)+'00.png'
    print(figname)
    plt.savefig(figname,bbox_inches='tight')
    t2 = time.clock()
    t3=round(t2-t1, 3)
    print(repr(t3)+" seconds to plot pcp for: "+dom)
      
    t3dom=round(t2-t1dom, 3)
    print(repr(t3dom)+" seconds to plot ALL for: "+dom)
    plt.clf()
    t3all=round(t2-t1a,3)
    print(repr(t3all)+" seconds to run everything!")

  
  
