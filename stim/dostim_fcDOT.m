function dostim_fcDOT(systype,TotTime,filename)
%
% dostim_fcDOT(systype,TotTime,filename)
%
% Present fixation cross for TotTime minutes.
%
% First Input: systype
% 'DOT' Normal DOT operation
%
% Second Input: TotTime = duration (in minutes) of main fixation cross time
% period.  That time period will occur between an initial fixation period
% of 2 seconds and a final fixation period of 5 seconds.
%
% Third Input: filename (text string)
% Text files with stimulus design and timing information will be outputted.
% They will be named filename-steps.txt and filename-times.txt; for
% example, if filename is 'fcDOT_test', then these files will be named
% fcDOT_test-steps.txt and fcDOT_test-times.txt.
%
%
% IMPORTANT!
% TO BREAK THE PROGRAM WHILE RUNNING:
% PRESS 'ALT-TAB' TO CHOOSE MATLAB CONTROL/COMMAND WINDOW
% FOLLOWED BY 'CTRL-C'.
%

%% Set Parameters
synchF=20;
synchA=25;
switch systype
    case 'DOT'
        TotTime=TotTime*60; % Read time in minutes.
    otherwise
        error('** Unknown system type **')
end

load('stim_AC') % Stimulus File

% Number of things stimulus will do
switch systype
    case 'DOT'
        numsteps=2; % total reps + initial fixation + final fixation
        Tif=2;%30;
end

load 'stim_blank'
stim.blank=stim_blank;
clear stim_blank
%% Create a struct that contains all the information about the stimulus
% "stim" is the stimulus to present: for flickering, just list number or name, not both flicker parities
% "command" is what to do with the stimulus: 'flicker' or 'hold'
% "time" is how long to do it: +number is a time in seconds, -number is a time in TTL pulses
% "hz" (only for flicker): flicker rate
steps(numsteps)=struct('stim',[],'command',[],'time',[],'hz',[],'synch',[],'display',[]);
InitializePsychSound;
c=PsychPortAudio('GetOpenDeviceCount');
if c~=0
    PsychPortAudio('Close')
end


% Construct Stimulus Protocol
% Intial Fixation
cstep=1; % Current Step of Stimulus
steps(cstep).stim='blank';
steps(cstep).command='hold';
steps(cstep).time=Tif; %30
steps(cstep).hz=0;
steps(cstep).synch=synchF;
steps(cstep).display='Intial Fixation';


% resting state fixations
cstep=cstep+1;
steps(cstep).stim='blank';
steps(cstep).command='hold';
steps(cstep).time=TotTime;
steps(cstep).hz=0;
steps(cstep).synch=synchA;
steps(cstep).display='Resting State epoch';

% Final Fixation
cstep=cstep+1;
steps(cstep).stim='blank';
steps(cstep).command='hold';
steps(cstep).time=5;
steps(cstep).hz=0;
steps(cstep).synch=synchF;
steps(cstep).display='Final Pulse';

% Final Pulse
cstep=cstep+1;
steps(cstep).stim='blank';
steps(cstep).command='hold';
steps(cstep).time=2;
steps(cstep).hz=0;
steps(cstep).synch=synchF;
steps(cstep).display='Final Pulse';

        
%% Generate output files and run stimulus

% Output text file of stimulus design
if exist('filename','var')
    stimfile(steps,[filename,'-steps.txt'])
end


% Screen('Preference', 'ConserveVRAM', 4096); % Beam Query Error Workaround
% Perform Stimlus
switch systype
    case 'DOT'
        Rush('time=dostim2(systype,stim,steps);',1);
        if exist('filename','var')
            timefile(time,[filename,'-times.txt'])
        end
end