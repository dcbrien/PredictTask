function [sac, thres] = EL1k_findsacs_2015(trials,SAMP_INT,TMULT,ct, D)
% function [sac, thres] = EL1k_findsacs_2015(trials,SAMP_INT,TMULT,ct, )
%
% thres     the calculated threshold(usu:-1 {auto})
% sacs      [sIND, eIND, sXY, eXY, dX, dY, AMPL, pVel, ANG, DUR, hasBlink]
%
% trials    from the F.trials(tr) structure the current trial number with x,y,s,a
% SAMP_INT  how many ms per data point(F.SAMP_INT; usu:2)
% TMULT     multiplier for stats (F.TMULT; usu:2)
% ct        a custom threshold may be used, otherwise this should be -1
% D is the Default options structure. must be in this order:
%     D.FIX_CUTOFF=30;
%     D.MIN_VEL=30;   % Minimum allowed velocity
%     D.MIN_DUR=10;   % has to last 10ms
%     D.TOOLONG=300;	% a saccade can't last more than 300ms
%     D.TOOCLOSE=10;  % speed has to stay below thres for 10ms to be independent
%     D.TOOSLOW=150;  % don't combine close saccades if the eariler one is 100DPS slower than later one
%  
% D should come from Q for all automarking constants (yet to be fully implemented)
%
% This is a wrapper function for findsacs_2015.mex
% works by sending only the specific trial data instead of the entire F
% structure. the wrapper makes sure the inputs match the requirments of
% the mex.
%
% type: D=EL1k_findsacs_2015; to get default settings.
%
% Brian Coe coe@queensu.ca 2015

% trials=F.trials(1);
% SAMP_INT=F.SAMP_INT;
% TMULT=F.TMULT;


if nargin<5
    D.FIX_CUTOFF=30;
    D.MIN_VEL=30;   % Minimum allowed velocity
    D.MIN_DUR=10;   % has to last 10ms
    D.TOOLONG=300;	% a saccade can't last more than 300ms
    D.TOOCLOSE=10;  % speed has to stay below thres for 10ms to be independent
    D.TOOSLOW=150;  % don't combine close saccades if the eariler one is 100DPS slower than later one
end
if nargin==0 & nargout ==1 %#ok<AND2>
    sac=D;% return the default settings
    return
end

if nargin<2
    help (mfilename)
    return
end
% if nargin<2% can't default this...
%     SAMP_INT=2;
% end
if nargin<3
    TMULT=2;
end
if nargin<4
    ct=-1;
end

%addons
D.TMULT=TMULT;
D.THRES=double(ct);

% just to be sure.
%trials.x=single(trials.x);
%trials.y=single(trials.y);
trials.s=single(trials.s);
%trials.a=single(trials.a);

try
[sac, thres] = findsacs_2015(trials.x,trials.y,trials.s,trials.a,SAMP_INT,D);
thres=single(thres);
ttt=fieldnames(sac);
for ii = 1:length(ttt)
    sac.(ttt{ii})=single(sac.(ttt{ii}));
end
catch
    printf('*** findsacs_2015 failed\n')

drawnow
thres=0;
sac=get_a_Sac;
end