function time=dostim2(systype,stim,steps,screen_on)

% This function executes the stimulus protocol in the "steps" struct array
% created by the function that calls dostim2.
%
% Input Parameters:
% - systype is either 'DOT' or 'MRI'.
% - stim is a stimulus data structure supplied by one of the "higher-level"
% stimulus presentation functions that calls dostim2.
% - steps is the structure array that describes the stimulus protocol that
% dostim2 is being asked to execute.
% - screen_on is 'ON', 'OFF', or 'OTHER' (default).
%


%% Prepratory Stuff
[sys]=readkeyfile([systype,'.txt']);    % Stimulus style key-file
if ~exist('screen_on','var'),screen_on='OTHER';end

Screen('CloseAll');                     % Reset Psychtoolbox
Screen('Preference', 'Verbosity', 0);   % Turn dialogue except warnings(1).  When set to 4, this caused erratic scrolling behavior in the MATLAB command window.
Screen('Preference', 'SkipSyncTests', 1);
screens=Screen('Screens');              % Detect monitors
numscreen=max(screens);
if numscreen>1,sys.screen='multi';else sys.screen='one';end
win=numscreen;   %number 2              % Screen for Stimulus
[sinfo]=screeninfo(win);                % Get information about screen
numsteps=numel(steps);                  % Get info about stimulus

AssertOpenGL;                           % Turn on good drawing tools
devices = PsychPortAudio('GetDevices'); % Audio hardware 

switch screen_on
    case 'ON'
        load 'stim_blank'
        [grid.width grid.height Ncol]=size(stim_blank);
        % Get locations of stimulus presentations
        rect=getRect(sys,grid,sinfo);
        s=win;  %number 2
        w(s)=Screen('OpenWindow',s,sinfo(s).gray); % gray to black 7/22/15
        grid.blank=stim_blank;        
        tex=stim2tex(grid,w(s));        % Draw Textures
        Screen('DrawTexture',w(s),tex.blank,rect.src,rect.dst);
        Screen('Flip',w(s),[],[],[],1);
        
    case 'OFF'
        Screen('CloseAll');
        load 'stim_blank';
        [stim.width stim.height Ncol]=size(stim_blank);
        % Get locations of stimulus presentations
        rect=getRect(sys,stim,sinfo);
    case 'OTHER'                % general prep
        Screen('CloseAll');
        load 'stim_blank'
        [stim.width stim.height Ncol]=size(stim_blank);
        % Get locations of stimulus presentations
        rect=getRect(sys,stim,sinfo);
        sys.synch = 'audio';
        synch.count=0;
        synch.method=sys.synch;
end

[center(1), center(2)] = RectCenter(rect.total(1,:));
for n=1:numsteps
    synch.data(n,:) = sin(linspace(0,2*pi*steps(n).synch(1),4410)');%4410
end


Ndev=length(devices);
keep=zeros(Ndev,1);
for j=1:Ndev
    % Search based on the main part of the sound card name according to
    % PsychPortAudio.
    expectedSoundCardNameMainPart = 'Scarlett 6i6 USB: USB Audio';  % Replace with main part of name of sound card according to PsychPortAudio('GetDevices').
    if isempty(strfind(devices(1,j).DeviceName, expectedSoundCardNameMainPart))
        keep(j) = 0;
    else
        keep(j) = 1;
    end
end
Didx=devices(1,keep==1).DeviceIndex;
pahandle = PsychPortAudio('Open',Didx,[],1,[],3,[]);



%% Present Stimulus
time=0;wl=0;md=0;sd=0;TotTime=GetSecs;
for n=1:numsteps
    TotTime(end+1)=GetSecs;
    disp([steps(n).display,'. Step Time = ',...
        num2str(TotTime(end)-TotTime(end-1))])
    sname=steps(n).stim;
    time(end+1)=time(end)+TotTime(end)-TotTime(end-1);
    switch steps(n).command
        case 'hold'
            if n==1,% Prep with blank screens and get window-pointers
                w=Screen('OpenWindow',win,sinfo(win).gray);
                Screen('BlendFunction',w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                Priority(MaxPriority(w))
                vbl=Screen('Flip', w);  % Do initial flip...
                tex=stim2tex(stim,w);   % Draw Textures
            end
            [synch,time]=holdstim(w,tex.(sname),...
                steps(n).time,rect,synch,n,time,pahandle);
            
        case 'flicker'
            if n==1,% Prep with blank screens and get window-pointers
                w=Screen('OpenWindow',win,sinfo(win).gray);
                Screen('BlendFunction',w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                Priority(MaxPriority(w))
                vbl=Screen('Flip', w);  % Do initial flip...
                tex=stim2tex(stim,w);   % Draw Textures
            end
            [synch]=flicker(w,tex.([sname,'a']),tex.([sname,'b']),...
                steps(n).time,steps(n).hz,rect,synch,n,pahandle);
            
        otherwise
            error(['** The stimulus style you have requested',...
                'is not supported **'])
    end
end

% Close out PsychToolbox and return control to MATLAB
PsychPortAudio('Close', pahandle);
Screen('CloseAll');


end