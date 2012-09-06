% -------------------------------------------------------------------------
% |                                                                       |
% |   Craig LaBoda                                                        |
% |   Duke University                                                     |
% |                                                                       |
% |   Function:     getLifetimesHough.m                                   |
% |   Description:  Takes in TCSPC data and returns the lifetimes         |
% |                 associated with any peaks found through a Hough       |
% |                 Transform                                             |
% |                                                                       |
% |   Inputs:       t - x values of histogram (usually times)             |
% |                 y - y values of histogram (usually counts)            |
% |                 dx - time/division from the TCSPC data                |
% |                 peaks - number of peaks of interest                   |
% |                                                                       |
% |   Outputs:      lifetimes - lifetime values calculated from the peaks |
% |                 lines - lines information returned by houghlines.m    |
% |                 peaks - peak information reaturned by houghpeaks.m    |
% |                 imageMat - the image translation of the histogram     |
% |                                                                       |
% -------------------------------------------------------------------------


function [H T R factor peakLifetimes] = getHough(t,y,dx,pks)

    % First take the log of the tcspc data
    log_y = log(y);
   
    % Taking the log makes creating coordinates for the image difficult  
    % because it introduces non-integer y values and we want to directly
    % translate the x and y values to image coordinate values.  Thus,
    % rather than just round and lose data, we can multiply by some factor
    % first and then round this scaled data (as long as we remove this
    % factor after finding our slopes).
    factor = 200;
    y_round = round(factor.*log_y);
    y_round(y_round==-inf)=0;
    y_round = y_round+1+abs(min(y_round));
    
    % Now create your image matrix
    yMin = min(y_round(y_round>0));
    yMax = max(y_round);
    imageMat = zeros(yMax-yMin, length(t));

    % Fill in the matrix
    for k=1:length(t)
        xCo = k;
        yCo = y_round(k);
        if ~(isnan(yCo) || yCo==0 || yCo==inf)
            imageMat(yCo,xCo) = 1;
        end
    end
     
    % Take the Hough Transform, find the peaks and lines
    [H, T, R] = hough(imageMat,'Theta',-89:.1:89,'RhoResolution',10);
    %houghstats;
    P  = houghpeaks(H,pks);%,'NHoodSize',[41 41]);
    
    % Calculate the lifetime from the peak's angle
    slope = tand(90.-T(P(:,2)));
    peakLifetimes = (1./(slope./dx)).*factor;
%     
%     % Get the hough lines
%     % Please note:  
%     % Default for FillGap is 30
%     % Default for MinLength is 40
%     L = houghlines(imageMat,T,R,P,'FillGap',40,'MinLength',40);
%     
% 
%     % If any lines or peaks were found then Iterate through the lines 
%     % and find the slopes
%     if (numel(L)>0)
%         for k = 1:numel(L)
%             x1 = L(k).point1(1);
%             y1 = L(k).point1(2);
%             x2 = L(k).point2(1);
%             y2 = L(k).point2(2);
%             m(k) = (y2-y1)/((x2-x1)*dx);
%             m(1,k) = m(k);
%         end
%         
%             % Convert the slopes to lifetimes
%             % Note: we need to multiply by the factor because we take the inverse
%             % of the slope
%             lineLifetimes = factor*(-1./m);
%     
%     % If no peaks or lines were found, then return a 0 lifetime
%     else
%         lineLifetimes = 0;
%     end

end