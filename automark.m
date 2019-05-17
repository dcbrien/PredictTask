% --------------------------------------------------------------------
% This automark function finds the index into the sac array for the first
% saccade after the target turns on
function sacons = automark(F, i)
% Automarks the current trial 
% sacinds  indicies of the saccades found after each target onset
% F   structure with F and user data (see GUIDATA)
% i         the current trial number

    sac=F.sac_Don{i};
    targeton=F.ton{i};
    n=length(targeton);
    
    TARGPRETIME=linspace(100, 300, n); % The amount of time before each target onset to
                                     % search for saccades.
    TARGPOSTTIME=500;  % The amount of time after target onset to search for saccades.
                                     
    MINAMPLITUDE=3;   % The minimum amplitude a saccade should have.                                 
    
    sacons=[];
    
    targetdir=F.targetdir(i);
    
    for j=1:n
        if isempty(sac)
            sacons=[sacons -9999];
            continue;
        end
        
        targetonind=find(F.trials_Don{i}(:,1)>=targeton(j), 1);
        
        curr_sacs=find(sac(:,1)>(targetonind-TARGPRETIME(j))&sac(:,1)<(targetonind+TARGPOSTTIME));
        
        if ~isempty(curr_sacs)
            % Calculate the amplitude of each saccade
            dX=[];
            amp=[];
            
            for s=1:length(curr_sacs)
                sacon=F.sac_Don{i}(curr_sacs(s),1);
                sacoff=F.sac_Don{i}(curr_sacs(s), 2);
                x=F.fixtrials{i}(sacon:sacoff, :);
                
                [minx, ix1] = min(x(:,1));
                [maxx, ix2] = max(x(:,1));
                [miny, iy1] = min(x(:,2));
                [maxy, iy2] = max(x(:,2));
                dX(s) = sign(ix2-ix1)*(maxx-minx);
                dY = sign(iy2-iy1)*(maxy-miny);
                amp(s)=sqrt(dX(s)*dX(s)+dY*dY);
            end
    
            dX=dX>=0;
            
            % Filter for saccade amplitude and direction
            curr_sacs=curr_sacs(amp>MINAMPLITUDE&dX~=targetdir);
            
            if ~isempty(curr_sacs)
                sacons=[sacons curr_sacs(1)];
            else
                sacons=[sacons -9999];
            end
        else
            sacons=[sacons -9999];
        end
        
        targetdir=~targetdir;
    end