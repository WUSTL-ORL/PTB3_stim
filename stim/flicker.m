function [synch]=flicker(s,stima,stimb,ftime,hz,rect,synch,n,pahandle)
%
% This function is called by dostim2 to present a pair of images that
% alternate ("flicker") for the desired duration.  A stim synch pulse is
% also generated just before the stimuli are displayed.
%
% Input Parameters
%   s       screen label for PTB3
%   stima   first stimulus in pair that will alternate/flicker
%   stimb   second stimulus in pair that will alternate/flicker
%   ftime   passed from command-line call, sets length of retinotopy
%           flickering at a given position. Generally, set to 1 sec for CW
%           and CCW, and 2 for OUT and IN.
%   hz      flicker frequency. fMRI/PET studies tell us 8Hz is the money.
%   rect    info about screen from getRect (obtained in dostim2)
%   n       step number
%  pahandle 'PTB3_CreateAudio_Synch' call info for audio
%
%

Tflicker = 0.5/hz;  % Time (sec) for each half cycle = 1/(2*hz) = 0.5/hz.
PTB3_CreateAudio_Synch(synch,n,pahandle);
Screen('DrawTexture',s,stima,rect.src,rect.dst);    % prep a
vts0=Screen('Flip',s);                              % initial flip
k = 1;
vts = vts0;
while (vts-vts0) < (ftime-Tflicker)
    if mod(k,2) == 1
        Screen('DrawTexture',s,stimb,rect.src,rect.dst);    % prep b
    else
        Screen('DrawTexture',s,stima,rect.src,rect.dst);    % prep a
    end
    [vts]=Screen('Flip',s,vts0+(k*Tflicker),0);
    k = k+1;
end
WaitSecs('UntilTime',vts0+ftime);