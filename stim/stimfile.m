function stimfile(steps,filename)

% Write text file with information about requested stimulus protocol
% described by the steps data structure.
%

numsteps=numel(steps);

f=fieldnames(steps(1));
numf=numel(f);

fid = fopen(filename, 'w');

for n=1:numf
    c=f{n};
    if n<numf
        c=strcat(c,'\t');
    else
        c=strcat(c,'\n');
    end
    fprintf(fid, c);
end

for s=1:numsteps
    for n=1:numf
        switch class(steps(s).(f{n}))
            case {'string','char'}
                c='%s';
            case 'double'
                c='%d';
        end
        if n<numf
            c=strcat(c,'\t');
        else
            c=strcat(c,'\n');
        end
         fprintf(fid, c, steps(s).(f{n}));
    end
end

fclose(fid);

end
