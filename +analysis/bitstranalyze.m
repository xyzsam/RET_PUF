% Sam Xi
% 4/4/12
% bytesTRANALYZE
%
% Performs various types of analyses on a bytestream of ciphertext.
% Currently, it can perform autocorrelation, crosscorrelation, and various
% measures of randomness and entropy of the bytestream.

function [out] = bytestranalyze(ciphertext, analysis_type)

if (nargin < 2)
    error('Not enough input arguments.');
end
nbytes = 8;
nGroup = 64/nbytes;
nValues = length(ciphertext);
bytes = zeros(1, nValues*nbytes);
bits = zeros(1, nValues*32);

% translate ciphertext into bytes
if (strcmp(class(ciphertext),'double'))
    
    for i=1:nValues
        val = ciphertext(i);
        s = ieee754(val);
        s_broken = [s(1:8); s(9:16); s(17:24); s(25:32);
            s(33:40); s(41:48); s(49:56); s(57:64)];
        bytes((i-1)*nGroup+1: i*nGroup) = bin2dec(s_broken)';
        bits((i-1)*64+1:i*64) = (s == '1111111111111111111111111111111111111111111111111111111111111111');
    end
elseif (ischar(ciphertext))
    fprintf('Char conversion...\n');
    if (mod(length(ciphertext),2) == 1)
        ciphertext(2:end+1) = ciphertext(1:end);
        ciphertext(1) = 0;
    end
    out = '';
    nValues = length(ciphertext);
    for i=1:nValues
        if (ciphertext(i) > 47 && ciphertext(i) < 58)
            out = strcat(out, dec2bin(ciphertext(i)-48,4)); % for ascii numbers
        elseif (ciphertext(i) ~= 0)
            out = strcat(out, dec2bin(ciphertext(i)-87,4)); % for ascii chars
        else
            out = strcat(out, '0000');
        end
    end
    for i=1:(length(out)/8)
        bytes(i) = bin2dec(out((i-1)*8+1:i*8));
    end
end

if (analysis_type == 1) % autocorrelation
    autocorr = xcorr(bytes, bytes);
    out = autocorr;
elseif (analysis_type == 2) % Shannon entropy
    
    range = max(bytes) - min(bytes);
    n = hist(bytes, range);
    
    p = n/sum(n);
    p = p(p~=0); % removes zero entries
    h = -sum(p.*log2(p));
    out = h;
end

end