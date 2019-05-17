function sac=get_a_Sac(Fsacs, whichsac)%, t
% function sac=get_a_Sac(Fsacs, whichsac)%
% bcoe
%     sac.sIND=0;
%     sac.eIND=0;
%     sac.sXY=[0 0];
%     sac.eXY=[0 0];
%     sac.dX=0;
%     sac.dY=0;
%     sac.AMPL=0;
%     sac.pVel=0;
%     sac.ANG=0;
%     sac.DUR=0;
%     sac.hasBlink=0;
%
if nargin==0
    if nargout==0
        help(mfilename)
    else
        sac.sIND=single(0);
        sac.eIND=single(0);
        sac.sXY=single([0 0]);
        sac.eXY=single([0 0]);
        sac.dX=single(0);
        sac.dY=single(0);
        sac.AMPL=single(0);
        sac.pVel=single(0);
        sac.ANG=single(0);
        sac.DUR=single(0);
        sac.hasBlink=false;
    end
    return
end
sac=struct();
remp=fieldnames(Fsacs);
for ii = 1:length(remp)
    sac.(remp{ii})=single((Fsacs.(remp{ii})(whichsac,:)));
end

end% function