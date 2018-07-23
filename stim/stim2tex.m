function tex=stim2tex(grid,w)
%
% This function converts visual stimuli stored in the fields of the input
% structure called 'grid' into a texture for display in the window with
% identifier w.  The texture corresponding to each stimulus is stored with
% the same field name in the output structure tex.
%

f=fieldnames(grid);
numf=numel(f);

for n=1:numf
    fname=f{n};
    tex.(fname)=Screen('MakeTexture', w, (grid.(fname)));
end

end