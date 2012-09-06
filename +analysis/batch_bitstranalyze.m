% Sam Xi
% 4/9/2012
% Batch analysis of ciphertext
%
% Runs entropy and autocorrelation analysis on a set of plaintext strings,
% where the symbols range from A to E.

cd ('D:\Documents\My Dropbox\Dwyer\Measurements\sa1 sa2 ix measurements');
load('mappingdb_ic0,0.mat');
cd('D:\Documents\My Dropbox\Dwyer\scripts\');

plaintext = ['AAAAA'; 'BBBBB'; 'CCCCC'; 'DDDDD'; 'EEEEE'; ...
             'ABABA'; 'ACACA'; 'ADADA'; 'AEAEA'; 'ABCDE'; 'rand '];
         
%% Processing
rand_str = rand(1,25);
autocorr = zeros(11, 399);
entropy = zeros(11, 1);
for i=1:size(plaintext, 1)-1
ciphertext = encrypt(plaintext(i, :), mappingdb, 4000, [0], 670, 'D:\Documents\My Dropbox\Dwyer\Measurements\sa1 sa2 ix measurements\', 'sa1');
fprintf('Encryption complete.\n');
deciphertext = decrypt(ciphertext, mappingdb, 4000, [0], 670, 'D:\Documents\My Dropbox\Dwyer\Measurements\sa1 sa2 ix measurements\', 'sa1');
fprintf('Decrypted text : %s\n', deciphertext);
autocorr(i, :) = bitstranalyze(ciphertext, 1);
entropy(i, 1) = bitstranalyze(ciphertext, 2);
end
autocorr(end, :) = bitstranalyze(rand_str, 1);
entropy(end, 1) = bitstranalyze(rand_str, 2);

%% Create autocorrelation plots
clf
figure(1);
for i=1:11
   subplot(3, 4, i) 
   plot(autocorr(i, :))
   title(plaintext(i, :));
end

%% Create entropy plots
figure(2);
plot(1:length(entropy), entropy, 'ko')
title('Entropy for the different strings')