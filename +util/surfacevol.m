% Sam Xi
% 09/14/11
% SURFACEVOL
%
% Computes the area under an arbitrary surface. The surface is given as a
% 2D matrix of values, and given epsilon-x and epsilon-y, the function
% performs a trapezoidal approximation to return the approximate area under
% that surface. Epsilon-x and y are the spacings between adjacent x and y
% points. The lower bound of the volume is the xy plane. The x-axis should
% correspond to the 1st dimension of the surface matrix, and the y-axis
% should correspond to the 2nd dimension. This algorithm computes the
% integral using an adapted trapezoid approximation.
%
%       SYNTAX: volume = surfacevol(surface, ex, ey)
%               surface = surface to compute volume under.
%               ex      = epsilon-x, which is the interval between adjacent
%                           x points.
%               ey      = epsilon-yu which is the interval between adjacent
%                           y points.

function volume = surfacevol(s, ex, ey) 
if (nargin ~=3)
    error('Incorrect number of parameters.');
elseif (length(ex) ~=1 || length(ey) ~= 1)
    error('Incorrect format of ex or ey - must a single value.');
elseif (size(s, 2) <=1)
    error('Incorrect format for surface - surface must be a 2D matrix.');
end

volume = 0;
syms xdummy;
for x=1:size(s, 1)-1
   for y=1:size(s, 2)-1
       % compute the area under the skew trapezoid by integrating the area
       % of infinitely many thin trapzeoids from x to x+1 (x_i and x_i+1).
       x1 = (x-1)*ex; x2 = x*ex;
       y1 = (x-1)*ey; y2 = y*ey;
       m1 = (s(x+1, y)-s(x,y))/ex;
       m2 = (s(x+1, y+1)-s(x, y+1))/ex;
       zf1 = @(xvar) m1*(xvar-x1) + s(x,y);
       zf2 = @(xvar) m2*(xvar-x1) + s(x,y+1);
       xlin = linspace(x1, x2, 10);
       integrand = @(xvar) ((ey/2) * (zf2(xvar) + zf1(xvar)));
       %volumeChunk = int((ey/2)*(zf2(xdummy)+zf1(xdummy)), xdummy, x1, x2);
       volumeChunk = (ex/9)*trapz(integrand(xlin));
       volume = volume + volumeChunk;
   end
end

end