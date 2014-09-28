function out=normalize(in)
    mag = magnitude(in);
    out(:,1) = in(:,1)./mag;
    out(:,2) = in(:,2)./mag;
    out(:,3) = in(:,3)./mag;
end