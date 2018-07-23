function [Rect]=getRect(sys,stim,sinfo)
%
% This function calculates the dimensions and position of an on-screen
% "destination" rectangle that should be used to display visual stimuli.
% This function is designed to scale the size of stimuli to a percentage of
% screen area as specified in the custom preferences text file for this
% system (e.g., 'DOT.txt') while preserving the aspect ratio of the
% stimuli.  This function also supports shifting the stimuli by an offset.
% In the custom preferences text file, the horizontal and vertical offsets
% from the upper left corner and the horizontal and vertical sizes (all in
% percentages of screen edge length) are specified by the following lines,
% where the numbers are replaced with the desired values (though this
% example fills the screen and centers the stimuli):
%
% hcenter 50
% vcenter 50
% hsize 100
% vsize 100
%
% Inputs:
% - sys is the output of readkeyfile for the system type (e.g., sys =
% readkeyfile('DOT.txt').
% - stim is a structure with fields 'width' and 'height' (stim.width,
% stim.height) that tell the dimensions of the stimulus in pixels.
% - sinfo is a screen information struct array that comes from the
% screeninfo() function.
%
% Output:
% - Rect is a data structure with fields 'src', 'total', and 'dst'.
% Rect.dst describes the destination rectangle as a 4-element vector:
% [offset(1) offset(2) horizontal_size vertical_size].  This describes the
% position and dimensions of the stimulus on the screen.  Rect.src is a
% similar vector that describes the part of the stimulus to display.
% Rect.total(j,:) is a similar vector that describes the rectangle that
% would exactly fill the screen with screen ID number j.
%

numscreen=numel(sinfo);

% Part of Stimulus to Use
Rect.src = [0 0 stim.width stim.height];

% Total Screens
for s=1:numscreen
    Rect.total(s,:)=[0 0 sinfo(s).width sinfo(s).height];
end

% Info for making Rect.dst
stimratio=stim.width/stim.height;
screenratio=sinfo(numscreen).width/sinfo(numscreen).height;

if stimratio==screenratio
    dstw = sinfo(numscreen).width * (sys.hsize/100);
    dsth = sinfo(numscreen).height * (sys.vsize/100);
elseif stimratio<screenratio
    dsth = sinfo(numscreen).height * (sys.vsize/100);
    dstw=stimratio*dsth;
elseif stimratio>screenratio
    dstw = sinfo(numscreen).width * (sys.hsize/100);
    dsth=stimratio*dstw;
end

stimcenter=[(sys.hcenter/100)*sinfo(numscreen).width (sys.vcenter/100)*sinfo(numscreen).height];
destRect_unshifted = [0 0 dstw dsth];
Rect.dst = CenterRectOnPointd(destRect_unshifted, stimcenter(1), stimcenter(2));

if any([Rect.dst(1)<Rect.total(s,1) Rect.dst(2)<Rect.total(s,2) Rect.dst(3)>Rect.total(s,3) Rect.dst(4)>Rect.total(s,4)])
    disp('** You asked for a destination Rect that exceeded the bounds of the screen. **')
    warning('** You asked for a destination Rect that exceeded the bounds of the screen. **')
end

end