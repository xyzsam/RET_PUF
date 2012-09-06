function tcspcData = parseTCSPC(filename, smoothFactor, timePerChannel)

numHeader = 10;
fid = fopen(filename);

if (fid == -1)
    error('File does not exist!');
else
    header = cell(numHeader,1);
    for i=1:numHeader
       header{i} =  fgetl(fid);
    end
    tcspcData(:,1) = [0:timePerChannel:4095*timePerChannel]';
    for i=1:size(tcspcData,1)
        tcspcData(i,2) = str2double(fgetl(fid));
    end
    fclose(fid);
    tcspcData(:,2) = smooth(tcspcData(:,2),smoothFactor);
end

end