function get_hdf5_data,hd_name,filename;
  hd_id=h5f_open(hd_name)
  sd_id=h5d_open(hd_id,filename)
  data=h5d_read(sd_id)
  return,data
  h5d_close,sd_id
  h5f_close,hd_id
end
function get_hdf5_att_data,hd_name,filename,sds_name;
  hd_id=h5f_open(hd_name)
  sd_id=h5d_open(hd_id,filename)
  sds_id=h5a_open_name(sd_id,sds_name)
  data=h5a_read(sds_id)
  return,data
  h5d_close,sd_id
  h5f_close,hd_id
end
pro fy3d_glt
  dir="E:\FYdata\A202208170076154903\"
  file_list=file_search(dir,'*250M_MS.HDF',count=file_n)
  for file_i=0,file_n-1 do begin
    band_nir=get_hdf5_data(file_list[file_i],'/Data/EV_250_RefSB_b4/')
    band_red=get_hdf5_data(file_list[file_i],'/Data/EV_250_RefSB_b3/')
    nir_slope=get_hdf5_att_data(file_list[file_i],'/Data/EV_250_RefSB_b4/','Slope')
    red_slope=get_hdf5_att_data(file_list[file_i],'/Data/EV_250_RefSB_b3/','Slope')
    nir_intercept=get_hdf5_att_data(file_list[file_i],'/Data/EV_250_RefSB_b4/','Intercept')
    red_intercept=get_hdf5_att_data(file_list[file_i],'/Data/EV_250_RefSB_b3/','Intercept')
    cal=get_hdf5_data(file_list[file_i],'/Calibration/VIS_Cal_Coeff/')
    lat=get_hdf5_data(file_list[file_i],'/Geolocation/Latitude/')
    lon=get_hdf5_data(file_list[file_i],'/Geolocation/Longitude/')
    size_data=size(band_nir)
    size_col=size_data[1]
    size_row=size_data[2]
    lat=congrid(lat,size_col,size_row,/interp);
    lon=congrid(lon,size_col,size_row,/interp)
    lon_min=min(lon)
    lat_max=max(lat)
    cal_0=cal[0,*]
    cal_1=cal[1,*]
    cal_2=cal[2,*]
    ;print,cal_0
    nir_cal_0=cal_0[3]
    red_cal_0=cal_0[2]
    nir_cal_1=cal_1[3]
    red_cal_1=cal_1[2]
    nir_cal_2=cal_2[3]
    red_cal_2=cal_2[2]
    dn_nir=((band_nir ge 0) and (band_nir le 4095))*band_nir*nir_slope[0]+nir_intercept[0]
    ref_nir=nir_cal_2*dn_nir^2.0+nir_cal_1*dn_nir+nir_cal_0

    dn_red=((band_red ge 0) and (band_red le 4095))*band_red*red_slope[0]+red_intercept[0]
    ref_red=red_cal_2*dn_red^2.0+red_cal_1*dn_red+red_cal_0

    ndvi=float(ref_nir-ref_red)/(ref_nir+ref_red)
    write_tiff,dir+file_basename(file_list[file_i],'.HDF')+'_ndvi.tiff',ndvi,/float
    print,ndvi
    print,'11111'
  endfor
end