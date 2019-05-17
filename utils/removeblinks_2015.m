% MEXFUNCTION trial = removeblinks_2015(rawtrials,res, D)
% use EL1k_removeblinks_2015 wrapper to properly shape data.
%
% rawtrials:  from the F structure from F=el2mat(filename);
% res:        is the resolutions structure. must be in this order:
%   res.pix_wide
%   res.pix_high
%   res.rec_rate
%   res.PPD
%
% D is the Default options structure. must be in this order:
%   D.BLINK_T=10000;          % Blink Threshold
%   D.PUPIL_BLINK_LEN_T=10;   % This is the minimum length of loss of eye tracking data to be considered a blink
%   D.PA_SEARCHT=25;          % Number of sample points to look examine pupil area before and after blink
%   D.SHRINK_BACKGROUND=50;   % similar to FIX_CUTOFF in findsacs_2015
%   D.MIN_PEAK=2;
%
% should come from Q for all automarking constants (yet to be fully implemented)
%
% 2014-nov to 2015-feb: MASSIVE REVAMP. combination of don's "pa_dd" (2nd derivative) & peaks and
% bcoe's "shrinkage" (1st derivative) & threshold of area,
% big problem was many sacs don't have the fixed peaks the peak algorytm looked for.
%
% Brian Coe: coe@queensu.ca  and  Donald Brien: briend@queensu.ca
