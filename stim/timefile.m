function timefile(time,filename)

% Write text file with event times recorded in the array 'time'.

fid = fopen(filename, 'w');

fprintf(fid,['FlickerTimes ',num2str(time(:)')]);

fclose(fid);

end
