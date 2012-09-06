clear all; close all; clc;
import hough.*;

%dx = 12.2e-12;
%dx = 6.11e-12;
%dx = 4.07e-12;
%dx = 3.05e-12;
dx = 1.22e-11;

synTau1 = 3.9e-9;
synTau2 = 4.1e-9;

isRealData = 1;
%dirName = [pwd];
%dirName = 'D:\Documents\Education\Duke\PhD\Experiments\Real\Exp2\Vishwa\survey day 5\';
%dirName = 'D:\Documents\Education\Duke\PhD\Experiments\Real\Exp2\Siyang\';
dirName = 'E:\Documents\Dropbox\Dwyer\Measurements\sam-114_1\1\';

if (isRealData)
    %~~~~ REAL DATA ~~~~%
    %filename = [dirName '12_1.asc'];
    filename = [dirName 'sa114_ic0_i10,10_em620.asc'];
    %filename = [dirName '19_647_670_m2.asc'];
    parsedData = parseTCSPC(filename,1,dx);
    orig_x = parsedData(:,1);
    orig_y = parsedData(:,2);
    sIndex = 1;
    eIndex = length(orig_x);
    %sIndex = 3200;
    %eIndex = 3721;
    orig_x = orig_x(sIndex:eIndex,1);
    orig_y = smooth(orig_y(sIndex:eIndex),1);
    %~~~~~~~~~~~~~~~~~~~%
else
    %~~~~ TEST DATA ~~~~%
    load af488p2_af647p3;
    orig_x = xx;
    orig_y = exp(yy);
    %~~~~~~~~~~~~~~~~~~~%
end

orig_log_y = log(orig_y);
x = orig_x; y = orig_y;

x(orig_log_y==-Inf) = [];
y(orig_log_y==-Inf) = [];
log_y = log(y);

calculatedLifetimes = zeros(5,1);

figure('Color',[1 1 1]);
subplot(2,3,1);
%plot(orig_x./dx,orig_y); title('Original measurement');
scatter(1:length(orig_y),orig_y, '.'); title('Original measurement');
subplot(2,3,4);
%plot(1:length(log_y),log_y); title('Semi-log of original');
scatter(1:length(log_y),smooth(log_y,1), '.'); title('Semi-log of original');

b = input('b? ');
e = input('e? ');
%b = 114;
%e = 2225;

% Calculate lifetime using the hough method without window
try
pks = 3;
[peakLifetimesA LA imageMatA TA RA HA tempA factorA] = getLifetimesHough(x,y,dx,pks);
calculatedLifetimes(1,1) = peakLifetimesA(1);
subplot(2,3,2);
imshow(imageMatA)
hold on
for k = 1:numel(LA)
    x1 = LA(k).point1(1);
    y1 = LA(k).point1(2);
    x2 = LA(k).point2(1);
    y2 = LA(k).point2(2);
   plot([x1 x2],[y1 y2],'Color','g','LineWidth', 1) ;
end
clear x1 x2 y1 y2;
title('Hough lines - no window');
catch
end

% Calculate lifetime using the hough method with window

[peakLifetimesB LB imageMatB TB RB HB tempB factorB] = getLifetimesHough(x(b:e),y(b:e),dx,pks);
calculatedLifetimes(2,1) = peakLifetimesB(1);
calculatedLifetimes(3,1) = tempB;
subplot(2,3,5);
imshow(imageMatB)
hold on
for k = 1:numel(LB)
    x1 = LB(k).point1(1);
    y1 = LB(k).point1(2);
    x2 = LB(k).point2(1);
    y2 = LB(k).point2(2);
   plot([x1 x2],[y1 y2],'Color','g','LineWidth', 1);
end
clear x1 x2 y1 y2;
title('Hough lines - with window');


% Calculate lifetime using the line between two points
try
window = 5;
xx2 = mean(x(e-window:e+window)); yy2 = mean(log_y(e-window:e+window));
xx1 = mean(x(b-window:b+window)); yy1 = mean(log_y(b-window:b+window));
mm = (yy2-yy1)/(xx2-xx1);
y_int = yy2-mm*xx2;
calculatedLifetimes(4,1) = -1/mm;
subplot(2,3,3);
plot(x,log_y); title('Two-point line'); hold on;
plot(x,mm.*x+y_int,'r','LineWidth',3);
catch
end


% Calculate liftime using the histogram of slopes method
try
lineLength = floor(length(x)/3); %%%%% TWEAKABLE %%%%%
traverseVector = b:e-lineLength;
taus = zeros(length(traverseVector),1);
for j=1:length(traverseVector)
    i = traverseVector(j);
    x2 = x(i+lineLength); y2 = log_y(i+lineLength);
    x1 = x(i); y1 = log_y(i);
    m = (y2-y1)/(x2-x1);
    taus(j) = -1/m;
end

taus(taus==-Inf) = [];
taus(taus<0) = []; taus(taus>1e-8) = [];
histx = 0:5e-11:1e-8;
histy = hist(taus,histx);
subplot(2,3,6);
bar(histx,histy); title('Histogram of lifetimes');
calculatedLifetimes(5,1) = max(histx(histy==max(histy)));
catch
end

clc;fprintf('\n\n     ~~~~~~~~~~~~ Lifetimes ~~~~~~~~~~~~\n');
fprintf('     Hough (wihout window)   : %.2e\n', calculatedLifetimes(1));
fprintf('     Hough (with window)     : %.2e\n', calculatedLifetimes(2));
fprintf('     Hough avg - with window : %.2e\n', calculatedLifetimes(3));
fprintf('     Two-point line          : %.2e\n', calculatedLifetimes(4));
fprintf('     Histogram of short lines: %.2e\n\n\n', calculatedLifetimes(5));

% figure('Color',[1 1 1]);
% subplot(1,3,1);
% set(gca,'FontSize',24);
% scatter(orig_x./dx,orig_y,'.'); title('Original', 'FontSize',24);
% xlabel('Time (indices)','FontSize',24); ylabel('Counts','FontSize',24);
% subplot(1,3,2);
% set(gca,'FontSize',24);
% scatter(x,log_y,'.'); title('Semilog + Two-point line','FontSize',24); hold on;
% xlabel('Time (s)','FontSize',24); ylabel('Counts (log)','FontSize',24);
% plot(x,mm.*x+y_int,'r','LineWidth',3);
% subplot(1,3,3);
% axis off;
% imshow(imageMatB); title('Hough Lines','FontSize',24);

H = HB; T = TB; R = RB; factor = factorB;
houghSpace;
