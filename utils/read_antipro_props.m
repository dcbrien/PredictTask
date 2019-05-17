function props=read_antipro_props(filename)
% function props=read_antipro_props(filename)
% a standalone modular version for QA
% coe@queensu.ca   11-nov-2015

%pname='C:\Users\BCoe\DATA\ONDRI\OND01_EBH_1001_01_SE04_EYT\scans\1\EYT\';
%fname='OND01_EBH_1001_01_SE04_EYT_AntiPro1_subject_props.txt';
%filename=[pname fname];

fid=fopen(filename);
props=[];
[p,f,e]=fileparts(filename);
if fid<1
    psyf=dir([p filesep '*' e]);
    if isempty(psyf)
        fprintf('*** no subject_props file  in folder:\n*** %s',p);
        return
    else
        [~,f]=fileparts(psyf(1).name) ;
        fid=fopen([p filesep f e] );
        if fid<1
            error([f e ' exists but cant be opened'])
        end
    end
end
props.filename=[f e];
tline = fgetl(fid);
ii=1;
while ischar(tline)
    switch ii
        case 1
            props.comment1=tline;
        case 2
            props.comment2=tline;
        otherwise
            C = strsplit(tline,'=');
            if strmatch(C{1},'Date_of_Birth')
                C{1}='AiM';
                C{2}=num2str(round(str2num(C{2})));
            end
            props.(C{1})=C{2};
    end        
    tline = fgetl(fid);
    ii=ii+1;
end
fclose(fid);
