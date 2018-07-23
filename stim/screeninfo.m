function [sinfo]=screeninfo(numscreen)
%
% This function obtains resolution- and size-related information about each
% stimulus display screen and also sets each such screen to operate at 32
% bits per pixel and 60-Hz refresh rate.  numscreen is the ID number of the
% last screen connected to the computer (maximum ID number of the screens).
% sinfo is a struct array containing the final settings for each stimulus
% display screen.
%

for s=1:numscreen
    sinfo(s)=Screen('Resolution',s);
    if sinfo(s).pixelSize~=32
        sinfo(s).pixelSize=32;  % Will force 32 bits per pixel.
    end
    if sinfo(s).hz~=60
        sinfo(s).hz=60;  % Will force screen to operate at 60-Hz refresh rate.  Monitors and video card must be able to support this.
    end
    sinfo(s)=Screen('Resolution',s,sinfo(s).width,sinfo(s).height,...
        sinfo(s).hz,sinfo(s).pixelSize);  % Apply new settings.
end

for s=1:numscreen
    sinfo(s).white=WhiteIndex(s);
    sinfo(s).black=BlackIndex(s);
    sinfo(s).gray=(sinfo(s).white+sinfo(s).black)/2;
end

end