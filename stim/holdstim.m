function [synch,time]=holdstim(s,stim,holdtime,rect,synch,n,time,pahandle)
%
% This function is called by dostim2 to display a static image (which could
% be a fixation cross) for a desired amount of time.  A stim synch pulse is
% also generated just before the stimulus is displayed.
%
% Input Parameters
%   s       screen label for PTB3
%   stim    stimulus to display
%   holdtime   duration (in seconds) to display stimulus
%   rect    info about screen from getRect (obtained in dostim2)
%   n       step number
%   time    currently unused input, kept for historical reasons
%  pahandle 'PTB3_CreateAudio_Synch' call info for audio
%



%% Present Fixation and send synch pulse
Screen('DrawTexture',s,stim,rect.src,rect.dst); 
time(end+1)=Screen('Flip',s,[],[],[],1);
PTB3_CreateAudio_Synch(synch,n,pahandle);
WaitSecs(holdtime);