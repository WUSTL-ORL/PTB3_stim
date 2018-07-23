%% Program Description
%
% Author: Zachary Markow (Email: zemarkow@wustl.edu)
%
% startup.m file for user "user" on Culver lab's SuperLogics stimulus
% computer.  Should be placed so that the file's full path is
% /home/user/Documents/MATLAB/startup.m .
%
% This file should be placed in a folder on MATLAB's initial search path
% for each user account on the computer.  This file will be automatically
% executed whenever MATLAB is started.  For the SuperLogics computer with
% operating system Ubuntu 16.04 LTS, the user-specific folder
% /home/username/Documents/MATLAB is on the search path when MATLAB starts.
% Therefore, a good place for this startup.m file for a user called "user"
% is /home/user/Documents/MATLAB/startup.m .
%
% Throughout this script, "clear all" is avoided so that the script does
% not clear variables that are needed by other MATLAB startup scripts.


%% Decide whether to display messages to tell the user what is happening at each step.

displayStatusMessages = false;  % true or false.


%% If desired, tell the user that this startup.m script is running.

if displayStatusMessages
   display('----- Running startup.m -----')
   display(' ')
end


%% Add extra software to MATLAB search path.

if displayStatusMessages
   display('Adding items to MATLAB search path.')
end

% Psychtoolbox 3.
PTB3_abs_path = '/usr/share/psychtoolbox-3';
if exist(PTB3_abs_path,'dir')
    addpath(genpath(PTB3_abs_path));
else
    display(['Warning: Could not find ' PTB3_abs_path ' .'])
end

% Culver lab's stimulus code files.
stim_code_abs_path = '/usr/share/stim';
if exist(stim_code_abs_path,'dir')
    addpath(genpath(stim_code_abs_path));
else
    display(['Warning: Could not find ' stim_code_abs_path ' .'])
end

clear PTB3_abs_path;

if displayStatusMessages
   display('--> Done.')
   display(' ')
end


%% Set visual debugging level to 3 in Psychtoolbox to suppress the Psychtoolbox startup/introduction screen and some visual debugging that might delay the start of a run of stimuli.

if displayStatusMessages
    display('Running Screen(''Preference'',''VisualDebugLevel'',3); to suppress Psychtoolbox startup screen.')
end

oldVisualDebugLevel = Screen('Preference','VisualDebugLevel',3);  % oldVisualDebugLevel is not used but is assigned here to avoid storing the setting as "ans".

if displayStatusMessages
   display('--> Done.')
   display(' ')
end

clear oldVisualDebugLevel;


%% Check that the expected sound card is on and visible to the computer.  If so, then set the computer to send sound output to the sound card.

% To do this, PulseAudio (abbreviated PA here) commands are executed as if
% from a Terminal.

if displayStatusMessages
   display('Checking visibility of expected sound card.')
end

% Print table of PulseAudio output devices ("sinks").
[~, audioOutputDevices_PA] = system('pactl list short sinks');

% Note that this code assumes that there are not multiple Focusrite
% Scarlett 6i6 USB sound cards connected to the computer.  This file will
% need to be modified if you want to connect and turn on more than one such
% sound card simultaneously.

soundCardNamePortion_PA = 'Focusrite_Scarlett_6i6_USB';
audioOutputDevices_PA = strtrim(audioOutputDevices_PA);  % Remove extra leading or trailing line breaks and other leading and trailing whitespace.
outputDeviceListArray_PA = strsplit(audioOutputDevices_PA, sprintf('\n'));  % Either sprintf('\n') or char(10) is required because MATLAB will not interpret a simple '\n' string declaration as a newline character.

soundCardDeviceIndexStr_PA = '';  % Will be replaced with the sound card's device ID/index as a string (e.g., '1', not 1) if and when the sound card is found.
keepSearching = true;
infoLineNum = 0;

while keepSearching
    infoLineNum = infoLineNum + 1;
    currentInfoLine = strtrim(outputDeviceListArray_PA{infoLineNum});
    % Only attempt to obtain information from the current line of text if
    % the current line has text (i.e., the line is not completely
    % whitespace).  Current line corresponds to a device if and only if it
    % contains text.  It is currently not necessary to account for the
    % possibility of blank lines between output device information lines
    % because we use "pactl list short sinks" and this command does not
    % place blank lines between sound output devices in the list, but in
    % case future versions of the command include such blank lines, the
    % code should work after the update.
    if ~isempty(currentInfoLine)
        currentDeviceInfo = strsplit(currentInfoLine);
        %currentDeviceName = currentDeviceInfo{2};
        if ~isempty(strfind(currentDeviceInfo{2}, soundCardNamePortion_PA))
           % Sound card has been found.  Record its PulseAudio output ID
           % index.
           soundCardDeviceIndexStr_PA = currentDeviceInfo{1};
        end
    end
    keepSearching = (infoLineNum < length(outputDeviceListArray_PA)) && isempty(soundCardDeviceIndexStr_PA);
end

if isempty(soundCardDeviceIndexStr_PA)
    % Sound card is not visible to the computer.  Suggest that the user
    % turn on the sound card and restart MATLAB.
    warning('ERROR: Expected sound card not found.  Make sure that it is on and then restart MATLAB.')
    display('ERROR: Expected sound card not found.  Make sure that it is on and then restart MATLAB.')  % Repeat the message as regular output in case user has warnings turned off.
else
    if displayStatusMessages
       display('--> Expected sound card found.  Selecting this sound card as the desired sound output device.')
    end
    
    % Sound card is on and visible to the computer.  Ensure that the
    % computer is set to send sound output to the sound card.
    [~,~] = system(['pacmd set-default-sink ' soundCardDeviceIndexStr_PA]);
end

clear soundCardNamePortion_PA audioOutputDevices_PA outputDeviceListArray_PA soundCardDeviceIndexStr_PA keepSearching infoLineNum currentInfoLine currentDeviceInfo;

if displayStatusMessages
   display('--> Done.')
   display(' ')
end


%% Change the current folder.

if displayStatusMessages
   %display('Changing current directory to ~ (this user''s home directory).')
   display('Changing current directory.')
end

cd /home/user/Scan_Stim_Output

if displayStatusMessages
   display('--> Done.')
   display(' ')
end


%% Open script that lists the main stimulus control commands.

if displayStatusMessages
    display('Opening script with main stimulus control commands.')
end

open([stim_code_abs_path filesep 'Typical_Retinotopy_Scan_Protocol.m']);

if displayStatusMessages
   display('--> Done.')
   display(' ')
end

clear stim_code_abs_path;


%% Tell the user that this script has finished if desired.

if displayStatusMessages
   display('----- Finished running startup.m -----')
   display(' ')
end


%% Clear remaining variables used in this script.

clear displayStatusMessages;