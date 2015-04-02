function time = time_in_day_date(cdf_date_time,CDATE)
    %
    %   function returns the time in seconds of the day CDATE 
    %    from CDF Epoch objects
    %
    start_day = datenum( [CDATE(5:6),'/',CDATE(7:8),'/',CDATE(1:4)] ) ;
    time = 86400 .* (cdf_date_time - start_day);
end