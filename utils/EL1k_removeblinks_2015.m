function trial = EL1k_removeblinks_2015(rawtrial,res, D)
% function trial = EL1k_removeblinks_2015(rawtrial,res, D)
%
%   rawtrial:  a (:,4) array with t,x,y,a in columns from the F structure from F=el2mat(filename);
%   res:        is the resolutions structure. must be in this order:
%     res.pix_wide
%     res.pix_high
%     res.rec_rate
%     res.PPD
%  
%   D is the Default options structure. must be in this order:
%     D.BLINK_T=10000;          % Blink Threshold
%     D.PUPIL_BLINK_LEN_T=10;   % This is the minimum length of loss of eye tracking data to be considered a blink
%     D.PA_SEARCHT=25;          % Number of sample points to look examine pupil area before and after blink
%     D.SHRINK_BACKGROUND=50;   % similar to FIX_CUTOFF in findsacs_2015
%     D.MIN_PEAK=2;
%  
%   D should come from Q for all automarking constants (yet to be fully implemented)
%  
%   2014-nov to 2015-feb: MASSIVE REVAMP. combination of don's "pa_dd" (2nd derivative) & peaks and
%   bcoe's "shrinkage" (1st derivative) & threshold of area,
%   big problem was many sacs didn't have the fixed peaks that the peaks only algorytm looked for.
%
% this is a wrapper function for removeblinks_2015.mex
% works by sending only the specific trial data (rawtrial,res) instead of the entire F
% structure. the wrapper makes sure the inputs match the requirements of the mex.
%
% type: D=EL1k_removeblinks_2015; to get default settings.
%
% Brian Coe coe@queensu.ca 2015

if nargin<3 % the default settings
    D.BLINK_T=10000;    % Blink Threshold
    D.PUPIL_BLINK_LEN_T=10;   % This is the minimum length of loss of eye tracking data to be considered a blink
    D.PA_SEARCHT=25;    % Number of sample points to look examine pupil area before and after blink
    %D.INTERP_SAMPS=5;  % Number of sample points before and after loss of data to base the interpolation on
    D.SHRINK_BACKGROUND=50;
    D.MIN_PEAK=2;
end
if nargin==0 & nargout ==1
    trial=D;% return the default settings
    return
end
if nargin<2
    help (mfilename)
    return
end

if size(rawtrial,2)~=4
    error('rawtrial data needs to have 4 columns');
end
% res must include this things in this order 
res2.pix_wide=res.pix_wide;
res2.pix_high=res.pix_high;
res2.rec_rate=res.rec_rate;
res2.PPD=res.PPD;

trial = removeblinks_2015(rawtrial,res2,D);
