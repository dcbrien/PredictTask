function [ang, ecc]=cart2polar(x, y, dig)
%
% Cartesian (x,y) to Polar (angle, eccentricity)
% e.g. [ang ecc]=cart2polar(7.07,7.07); returns ang=45.00; ecc=9.99848988597778;
%
% for ease of use you can specify how many digits to round off the calculation (0-13).
% e.g. [ang ecc]=cart2polar(7.07,7.07,2); returns ang=45; ecc=10;
%
% 2001 coded by bcoe@med.juntendo.ac.jp
if nargin<1
	help cart2polar
	return
end

if nargin<2 | sum(size( y )~=size( x ))
	if length(x)==2 & nargin==1
		y=x(2);
		x=x(1);
	else
		error('-> cart2polar X and Y must be of the same size and orientation')   
	end
end
if nargin<3
   dig=14;% round output to the significance on of my pi
end
if dig<0 | dig>14
   dig=14;
end

ang=((((atan2(y,x))<=0) * 360) + atan2(y,x)*(180/pi));
ecc=sqrt(x.^2+y.^2);
ang(ecc==0)=0;
if dig<14
	ang=round(ang*(10^dig)) / (10^dig) ;
	ecc=round(ecc*(10^dig)) / (10^dig) ;
end
return
