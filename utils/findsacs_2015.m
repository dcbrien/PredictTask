% MEXFUNCTION [sac, thres] = findsacs_2015(x,y,s,a,SAMP_INT,D);
% use EL1k_findsacs_2015 wrapper to properly shape data.
%
% x,y,s,a are vectors of single point data of equal length. (HorzX, VertY, Speed, Area)
%
% SAMP_INT is the number of milliseconds per data point. (e.g. 500Hz = 2)
%
% D is the Default options structure. must be in this order:
% D.FIX_CUTOFF=30;   % faster than this is not fixation.
% D.MIN_VEL=30;      % minimum allowed velocity
% D.MIN_DUR=10;      % saccade has to last 10ms
% D.TOOLONG=300;     % a saccade can't last more than 300ms
% D.TOOCLOSE=10;     % speed has to stay below thresh for 10ms to be independent
% D.TOOSLOW=150;     % 
% D.TMULT=2;         % STD multiplier for auto-thresholding
% D.THRES=-1;        % -1 is auto thresholding, larger than 1 is manual threshold.
%
% Brian Coe: coe@queensu.ca  and  Donald Brien: briend@queensu.ca
