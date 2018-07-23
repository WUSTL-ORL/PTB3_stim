function PTB3_CreateAudio_Synch(synch,n,pahandle)

% This function sends a call to the audio card using PsychPortAudio.
% synch: synch pulse data created within dostim2
% n:     step number
% pahandle: what it is everywhere...

data=[synch.data(n,:)-synch.data(n,:);...
    synch.data(n,:)-synch.data(n,:);...
    synch.data(n,:)];

PsychPortAudio('FillBuffer', pahandle,data);
PsychPortAudio('Start', pahandle );