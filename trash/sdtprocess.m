% SDTPROCESS
% 02/22/2012
% Sam Xi
%
% This function applies a windowing average to the data and saves the data 
% in a regular naming and directory format, so that the output can be used
% for encryption and decryption in a later stage.
% 
% USAGE	
%       data = sdtprocess(raw_data, filename)
%              raw_data   : data parsed from the TCSPC's ASCII output
%              filename   : the name of the file, which contains config
%							information about the experiment

function data = sdtprocess(raw_data, filename)


data = windowavg(raw_data, 10);

end