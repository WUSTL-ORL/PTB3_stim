function [fvalues]=readkeyfile(filename)

% readkeyfile(): Read key-file and export struct.
% 
% This program reads in the key-file data storage format. This format is
% used by This format is used by Acqdecode and the neuroDOT code to talk
% with each other, and to input processing commands into the Matlab
% experimental design programs.
% 
% Syntax: [fvalues]=readkeyfile(filename)
%
% filename is a struct containing the filename (with path and extension).
% fvalues is a struct containing the returned variables. The fields of
% this struct depend on the keys in the file. The interpretation of
% various keys is handled by the sub-program interpstring(). This includes
% a list of known strings and their formatting. Unknown strings are given
% field names that are simply the lower-case of their key name, and they
% are converted to doubles unless they contain any letters, in which case,
% they are retained as strings.
%

fvalues=struct; % initialize

if ~isstr(filename); error('** You entered a filename that was not a string**'); end
if ~strcmp(filename((end-3):end),'.txt'); filename=strcat(filename,'.txt'); end

fid=fopen(filename);

if fid==-1
    error(['** The key-file you requested (',filename,') does not exist **'])
end

readflag=1;
while readflag
    readstring=fgetl(fid);
    if readstring==-1 % End of File
        readflag=0;
    elseif (strncmp(readstring,'#',1) || strncmp(readstring,'%',1)) % Comment Line
        continue
    elseif strncmp(readstring,'!',1) % Include additional nested key-file
        fvalues2=readkeyfile(readstring(3:end));
        fvalues=mergestruct(fvalues,fvalues2);
    elseif isempty(readstring) % Blank Line
        continue
    else % if line with KEY VALUE
        [key value]=interpstring(readstring); % interpret line
        fvalues.(key)=value; % enter into struct
    end
end

fclose(fid);

end

%% interpstring()
function [key2 value]=interpstring(rs)

w=isstrprop(rs,'wspace'); % find white-space
kvsplit=find(w,1); % KEY/VALUE divide is the first white-space

key=rs(1:(kvsplit-1)); % Extract KEY
value=rs((kvsplit+1):end); % Extract VALUE (as string)

switch key
    % New naming convetion
    case {'ENCODING_NAME','PAD_NAME'}
        key2=lower(key(1:3));
    case 'NCOLOR'
        key2='cnum';
        value=str2double(value);
    case {'NDET','NSRC'}
        key2=[lower(key(2:end)),'num'];
        value=str2double(value);
    case {'P','W'}
        key2=key;
        value=str2double(value);
        
    % Use same name, keep value as string
    case {'NAME','DATE','TIME','TAG','COMMENT','GI','AHEM','CENT','SMETH',...
            'FLAGDIR','DIR','PATH','BASE','SHELL','LOGIC','INVERT'}
        key2=lower(key);
        
    % Use same name, change value to number
    % Scalars
    case {'UNIX_TIME','RUN','NREG','NTS','NSAMP','NBLANK','NMOTU','NAUX',...
            'DET','LOWPASS1','LOWPASS2','LOWPASS3','HIGHPASS','GSR','BTHRESH',...
            'OMEGA_LP1','OMEGA_LP2','OMEGA_LP3','OMEGA_HP','FREQOUT','STARTPT',...
            'CTHRESH','SEEDSIZE','GLOBREG','WRITECENT','STHRESH','RSTOL',...
            'PWAVE','PRATE','ABBELT','THBELT','PNCYCLE','HANDTHRESH',...
            'GBOX','GSIGMA','SHELLIN','SHELLOUT','ALIAS','NREG','NTS','NDIO',...
            'STEPL','BUFFL','FRAMEHZ','BUFFPERCENT'}
        key2=lower(key);
        value=str2double(value);
    % Vectors and Exponentials
    case {'FREQ','DIV','NN1','NN2','LAMBDA1','LAMBDA2','LEDHZ'}
        key2=lower(key);
        value=str2num(value);
        
    otherwise
        % disp(['** readkeyfile() encountered an unknown KEY: ',key,' **'])      
        key2=lower(key);
        if any(isstrprop(value,'alpha')) % Keep values with letters as strings
            % disp('  Maintaining ASCII format')
        else % Others turn into numbers
            % disp('  Converting to Double format')
            value=str2num(value); 
        end
end
end
