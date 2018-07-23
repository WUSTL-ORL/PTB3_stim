function dostimAC_new(systype,repnum,design,matrix_type,hz,filename)

% dostimAC_new(systype,repnum,design,matrix_type,hz,filename)
%
% Display alternating checkerboard wedge stimuli in lower left and lower
% right visual field quadrants.  Checkerboard wedge 'A' is in the lower
% right quadrant, and checkerboard wedge 'C' is in the lower left quadrant.
% Every time a stimulus is presented, the stimulus is followed by a resting
% period (fixation cross, here also called an interstimulus interval).
%
% Stimuli are timed according to the specified design during the main part
% of the stimulus presentation run.  There is also 1 initial fixation
% (resting) period and 2 final fixation periods.  The overall sequence is
% therefore: initial fixation (duration controlled by Tinit in code), main
% part of run, first final fixation (5 seconds), second final fixation (2
% seconds).
%
% First Input: systype
% 'DOT' Normal DOT operation
%
% Second Input: repnum
% Choose number of repetitions to do.  There are 2 stimuli per repetition.
%
% Third Input: design
% Choose paradigm type: 'Block', 'Event', 'Pseudo-Event', or 'Pseudo-Event2'.
% This affects stimulus timing and order.  See 'switch design' code block
% below for all details.  In summary:
% > 'Block' design presents stimuli for longer time periods and has a
% longer resting period after each stimulus (interstimulus interval); each
% trial = stimulus on for 10 sec, rest for 24 sec.  The order in which
% stimuli are presented is random.**
% > 'Event' design presents stimuli for shorter time periods and uses a
% shorter, pseudorandom interstimulus interval; each trial = stimulus on
% for 5 sec, rest for a duration chosen randomly from a uniform
% distribution from 2-15 sec.**  The order in which stimuli are presented
% is random.**
% > 'Pseudo-Event' is like 'Event' design but uses a predefined stimulus
% order and set of interstimulus interval lengths so that the stimulus
% order and interstimulus interval are random-like within a run but
% consistent between runs of this function.  When you use 'Pseudo-Event',
% the stimuli presented will be the first 2*repnum from the predefined
% order.  The predefined order has 30 stimuli.
% > 'Pseudo-Event2' is similar to 'Pseudo-Event' but has a larger number
% (50) of predefined stimuli and interstimulus intervals and a different
% distribution of interstimulus interval lengths.
%
% ** This function does not shuffle the random number generator (RNG) seed,
% so if you started MATLAB for a scan, ran this function with 'Block' or
% 'Event' design, closed MATLAB, and then repeated this process with
% identical settings on another day (e.g., with a different subject), then
% the stimulus order would be the same between the two scan sessions.  If
% you are running the same stimulus protocol like this in different scan
% sessions and you want the stimulus order to differ between the sessions,
% then you can run the command "rng('shuffle');" before running this
% function.  However, even if you do not shuffle the RNG seed, the stimulus
% order will still be random (technically pseudorandom) within a run of
% this function, and stimulus orders will not repeat themselves during a
% scan session unless you have to restart MATLAB in the middle of a scan.
%
% Fourth Input: matrix_type
% Choose matrix_type: 'stim_AC', 'stim_ACbig' or any matlab file name which
% contains stim matrices.  'stim_ACbig' is recommended.
%
% Fifth Input: hz
% Flicker frequency in Hz.  Recommended frequency is 8 Hz.
%
% Sixth Input (optional): filename
% Text files with stimulus design and timing information will be outputted
% if filename is specified as an input.  They will be named
% filename-steps.txt and filename-times.txt; for example, if filename is
% 'CCW_test', then these files will be named CCW_test-steps.txt and
% CCW_test-times.txt.
%
%
% IMPORTANT!
% TO BREAK THE PROGRAM WHILE RUNNING:
% PRESS 'ALT-TAB' TO SELECT THE MATLAB CONTROL/COMMAND WINDOW
% FOLLOWED BY 'CTRL-C'.
%


%% Set Parameters based on systype and design
synchF=20;  % Frequency of synch pulse F.
synchA=25;  % Frequency of synch pulse A.
synchB=30;  % Frequency of synch pulse B.
switch systype
    case 'DOT'
        numsteps=2*repnum+2; % total reps + initial fixation + final fixation
        Tinit=30;  % Initial fixation time in seconds.
    otherwise
        error('** Unknown system type **')
end

switch design
    case 'Block'
        % Blocks of Ton=10, Toff=24.
        Ton=10;% Flicker Time in seconds.
        ISI(1:2*repnum)=24;  % Inter-Stimulus Intervals (rest/fixation time after each AC stimulus in seconds).
        StimOrder=randperm(2*repnum);   % Odd number = stimulus C; even number = stimulus A.
    case 'Event'
        Ton=5;% Flicker Time
        ISI=round(rand(1,(2*repnum)).*13+2);
        StimOrder=randperm(2*repnum);
    case 'Pseudo-Event'
        Ton=5;% Flicker Time
        ISI=[4 13 9 15 3  8  3  15  2  12 13 13  3  7  5  12,...
            8  14  4  5  4  4  13  10  9  4  13 10 7 9];
        StimOrder=[3 3 3 3 2 3 3 3 2 2 2 3 2 2 3 2 3,...
            2 3 2 3 2 2 2  2 3 2 2 3 3 ];
    case 'Pseudo-Event2'
        Ton=5;% Flicker Time
        ISI=[7 4  8 5  6 4 9  5  8  3  7  6  10  7  8,...
            6 5 9  3 5 6 5  9  8  2 5  6  5 7  7 4  5,...
            5 8 3 3 5 4 6 5 10 8 3 8  4  5  6  9 5  10];
        StimOrder=[3 3 2 3 2 2 3 3 2 3 2 3 3 2 3 2 3 2,...
            3 2 3 2 2 3  2 3 2 2 3 2 3 2 2 3 3 2 3 2 3,...
            2  2 3 2 3  3 2 3 2 3 2 ];

    otherwise
        error('** Unknown design type **')
end

load(matrix_type)   % Stimulus File

%%initialize PsychSound and close open sound devices
InitializePsychSound;
c=PsychPortAudio('GetOpenDeviceCount');
if c~=0
    PsychPortAudio('Close')
end


%% Construct stimulus protocol.
% Create a struct called "steps" that contains all the information about
% the stimulus.  This structure has the following fields:
% - "stim" is the stimulus to present: for flickering, just list number or
% name, not both flicker parities.
% - "command" is what to do with the stimulus: 'flicker' or 'hold'.
% - "time" is how long to do it: +number is a time in seconds, -number is a
% time in TTL pulses.
% - "hz" (only for flicker): flicker rate.
steps(numsteps)=struct('stim',[],'command',[],'time',[],'hz',[],'synch',[],'display',[]);

% Intial Fixation
cstep=1; % Current Step of Stimulus
steps(cstep).stim='blank';
steps(cstep).command='hold';
steps(cstep).hz=0;
steps(cstep).synch=synchF;
steps(cstep).display='Intial Fixation';

switch systype
    case 'DOT'
        steps(cstep).time=Tinit;
end


% Main Stimulus Presentation Loop
for r=1:2*repnum
    
    % FLICKER
    cstep=cstep+1;
    if mod(StimOrder(r),2)  % Odd
        steps(cstep).stim='C';
        steps(cstep).display=['Cycle: ',num2str(r),', Stimulus: C'];
        steps(cstep).synch=synchB;
    else  % Even
        steps(cstep).stim='A';
        steps(cstep).display=['Cycle: ',num2str(r),', Stimulus: A'];
        steps(cstep).synch=synchA;
    end
    steps(cstep).command='flicker';
    steps(cstep).hz=hz;
    
    switch systype
        case 'DOT'
            steps(cstep).time=Ton;
    end
    
    % REST
    cstep=cstep+1;
    steps(cstep).stim='blank';
    steps(cstep).display=['Cycle: ',num2str(r),', Inter-Stimulus Interval'];
    steps(cstep).synch=synchF;
    steps(cstep).command='hold';
    steps(cstep).hz=0;
    
    switch systype
        case 'DOT'
            steps(cstep).time=ISI(r);
    end
    
end

% Final Pulse
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

Screen('Preference', 'ConserveVRAM', 4096); % Beam Query Error Workaround

% Perform Stimulus
switch systype
    case 'DOT'
        Rush('time=dostim2(systype,stim,steps);',1);
        if exist('filename','var')
            timefile(time,[filename,'-times.txt'])
        end
end
