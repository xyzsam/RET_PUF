% Sam Xi
% 03/10/11
% ZERODYE
%
% Zero-pads dye array. This corrects inconsistent dye information, since
% all dyes will have different beginning and ending wavelengths.
% It prepends and appends new wavelengths to the array, beginning from a
% start wavelegnth and ending at an end wavelength. The corresponding
% intensity values are 0.
% 
% SYNTAX:   
%           dye = zeroDye(dyeData, start, finish) extends the dye's
%                 wavelength data from start to finish.
%           dye = zeroDye(dyeData) uses the values of 1 and 1000 for start
%                 and finish, respectively.
%

function dye = zeroDye(data, start, finish)

if (nargin == 1)
    start = 1; finish = 1000;
elseif (nargin ~= 3)
    error('zeroDye: Invalid number of input parameters.')
elseif (size(data,2)~=2)
    error('Data is of the wrong size.')
end

dye = zeros(finish-start+1, 2);
dye(:, 1) = start:finish;
dye(data(1,1)-start+1:data(end,1)-start+1, 2) = data(1:end,2);
end