function [X, Y]=polar2cart(ang, ecc, dig)
%
% Polar (angle, eccentricity) to Cartesian (x,y)
% e.g. [X Y]=polar2cart(45,10); returns X=7.07106781186548; Y=7.07106781186547;
%
% for ease of use you can specify how many digits to round off the calculation (0-13).
% e.g. [X Y]=polar2cart(45,10,2); returns X=7.07; Y=7.07;
% e.g. [X Y]=polar2cart(45,10,1); returns X=7.1; Y=7.1;
% e.g. [X Y]=polar2cart(45,10,0); returns X=7; Y=7;
%
% coded by bcoe@med.juntendo.ac.jp
if nargin<1
	help polar2cart
	return
end
if nargin<2 
	[m, n]=size(ang);
	switch 2
		case n
			ecc=ang(:,2);
			ang=ang(:,1);
		case m
			ecc=ang(2,:);
			ang=ang(1,:);
		otherwise
			error('-> polar2cart angle and ecc must be of the same size and orientation')   
	end
end
if length(ecc)~=length(ang)
	error('-> polar2cart angle and ecc must be of the same size and orientation')   
end
if nargin<3
	dig=14;
end
if dig<0 | dig>14
	dig=14;
end
X=cos(ang/(180/pi)).*ecc;
Y=sin(ang/(180/pi)).*ecc;
if dig<14
	X =round( X *(10^dig)) / (10^dig) ;
	Y =round( Y *(10^dig)) / (10^dig) ;
end
return
