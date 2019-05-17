% function el2mat - By: Donald C. Brien (Oct. 16/08)
%   This function takes an eyelink edf file and returns some of the basic
%   data.
%
%   input: and EDF file from an Eyelink experiment
%   output:
%       E - A structure containing the events and eye data from the EDF
%       file.  The following fields are defined:
%           sampledata - t, x, y data from the experiment
%           eventdata - starttime, endtime, eventcode for eye events
%               (fixation, saccade and blink).
%           mestimes - the time that message events occured
%           messages - the text from message events.  This has the same
%               number of rows as mestimes.
%           preamble - the header text from the file
%           codes - eye event codes that can be used to index the eventdata
%               field.
function E=el2mat(fname)
    % Event codes
    EFIX=8;
    ESACC=6;
    EBLINK=4;

    try
        [sampledata eventdata mestimes messages preamble]=geteldata(fname);
    catch
        warning(['Error processing file: ' fname]);
        E=[];
        return;
    end
    sampledata=sampledata';
    eventdata=eventdata';
    mestimes=mestimes';
    m{length(mestimes),1}=''; % pre alocate for speed
    for i =1: size(messages,1)
        m{i,:}=messages(i,messages(i,:)>11);
    end

    E.sampledata=sampledata;
    E.eventdata=eventdata;
    E.mestimes=mestimes;
    E.messages=m;
    E.preamble=preamble;

    %% display information
    temp=findincell(E.messages,'GAZE_COORDS');
    pix = textscan(E.messages{temp(1)}, '%*s %*f %*f %f %f');
    temp=findincell(E.messages,'RETRACE_INTERVAL');
    ref = textscan(E.messages{temp(1)}, '%*s %f ');
    temp=findincell(E.messages,'MODE RECORD');
    rate=textscan(E.messages{temp(1)}, '%*s %*s %*s %f %*f %*f %*s ');

    E.res.pix_wide=pix{1}+1;
    E.res.pix_high=pix{2}+1;
    E.res.ref_rate=1000/ref{1}; % both should be in Hz....
    E.res.rec_rate=rate{1};
    E.res.SAMP_INT=1000/E.res.rec_rate;% MS per sample. used to turn IND to time

    E.codes.FIX=EFIX;
    E.codes.SACC=ESACC;
    E.codes.BLINK=EBLINK;
    
    