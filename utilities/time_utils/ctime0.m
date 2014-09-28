function tout = ctime0(str_day)
    %  
    %  function to produce the CTIME, seconds since Jan 1 1970,  for the beginning
    %  of a day set by a string CDATE , like  '20011023' for 23 Oct 2001
    %
    %  somehow leap seconds are not accounted for.....
    %
    %  referenced to 1 Jan 2000 which has a MATLAB datenum of 730486
    %
    %  946684800 seconds between Jan 1 1970 and Jan 1 2000
    %
    deld = datenum([str_day(5:6),'/',str_day(7:8),'/',str_day(1:4)]) - 730486;
    tout = deld*86400 + 946684800;
end