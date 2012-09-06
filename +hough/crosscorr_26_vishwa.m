clc
clear global
tic
global IX1 IX2 B C r n v z m r1 b1 x y s m1 k puf_1 e f g h Y G X Z eee



string=cell(100,1);
%File read
n = input( 'Enter number of files: ' );

cd ('D:\Documents\My Dropbox\Dwyer\Measurements\sa1 sa2 4-14-12')
%files = ls('*.asc');
for a = 1:size(files,1)
   filename = sprintf('%d.asc', a);   
   %filename = deblank(files(1,:));
   fid=fopen(filename, 'rt');   
    header = [fgetl(fid) fgetl(fid) fgetl(fid) fgetl(fid) fgetl(fid) fgetl(fid) fgetl(fid) fgetl(fid) fgetl(fid) fgetl(fid)];
    disp(header(10:38));
     puf_1(:,a) = fscanf(fid, '%i'); 
    fclose(fid);   
end

%Normalize
% puf_1 = normc(puf_1);
% puf_1 = puf_1*1000;
% puf_1 = round(puf_1);

%Cross-corr
% puf_1(all(puf_1==0,2),:)=[];
puf_1(puf_1 == 0) = 0.1;
C1 = corrcoef(puf_1);
C2 = corrcoef(log(puf_1));
%disp(C1)


%Image generation
%A = full(puf_1);

tp = 0.004:0.004:0.004*4095;
%tp = 1:4095;
t = transpose(tp);
rr = zeros(100,1);

for a = 1:2:n-1
    Y(:,a) = puf_1(:,a);
     Y(:,a+1) = puf_1(:,a+1);
     
Y(Y == 0) = 0.001;
X = zeros (4096,400);
Z = zeros (4096,400);

for b = 1:4094
    for c = 2:400
            if Y(b,a) == c
            X(b,round(log(c))) = log(Y(b,a));
            end
            if Y(b,a+1) == c
            Z(b,round(log(c))) = log(Y(b,a+1));
            end
    end
end

% X=X~=0;
% Z=Z~=0;



%plot(t, log(puf_1(:,1)));
% gg = nnz(X)
% hh = nnz(Z)
%g = nnz(X);
I = mat2gray(X);
%imshow(mat2gray(X))
J = mat2gray(Z);
imshow(mat2gray(Z))


%Hough transform
[H, T, R] = hough(X);
[H1, T1, R1] = hough(Z);


eee = zeros (8231,100);

iii1=11;
iii2=63;

for iii = iii1:iii2
    hhh =1;
for ggg = 1:8231
    
    if H(ggg, iii) || H1(ggg, iii) ~= 0
    eee(hhh,iii) = H(ggg,iii);
    eee(hhh,iii+(iii2-iii1+1)) = H1(ggg,iii);
    hhh = hhh+1;
    end
    
end  
end
eee(all(eee==0,2),:)=[];
eee = eee(:,any(eee));
%disp(nnz(eee))
C6 = corrcoef(eee, 'alpha', 0.01);

fff = zeros ((iii2-iii1+1),1);

for jjj = 1:(iii2-iii1+1)
    fff(jjj, 1) = C6(jjj, jjj+(iii2-iii1+1));
end

rr(a) = sum(fff)/(iii2-iii1+1);
string{a,1} = num2str(rr(a));


% str(8:16) = [];
% tt(a) = transpose(str);

% tt(a) = round(rr(a)*1000000);
% qq(a) = tt(a)/1000000;
% ss = transpose(qq);
%ss(all(ss==0,2),:)=[];
%rr(all(rr==0,2),:)=[];
% aaa = zeros (2,76);
% 
% aaa(1,46) = zeros;
% aaa(2,46) = zeros;
% 
% aaa = sum(H,1);
% bbb = sum(H1,1);
% 
% ccc(1,45:76) = (aaa(1,45:76));
% ccc(2,45:76) = (bbb(1,45:76));
% ddd = transpose(ccc);
% 
% ddd(all(ddd==0,2),:)=[];
 
% sumkk = 0;
% sumll = 0;
% summm = 0;
% normalize = 0;
% disp(sum(ddd(1)/32))
% for ii = 1:32
% 
%    
%   kk(ii) = ((ddd(ii,1) - mean(ddd(1), 1))*( ddd(ii,2) - mean(ddd(1),2)));
%   ll = (ddd(ii,1) - mean(ddd(1), 1))*(ddd(ii,1) - mean(ddd(1), 1));
%   mm = (ddd(ii,2) - mean(ddd(1), 2))*(ddd(ii,2) - mean(ddd(1), 2));
%   sumkk = sumkk + kk(ii);
%     sumll = sumll + ll;
%       summm = summm + mm;
% 
%   
% end
% 
%     nn = sqrt(sumll*summm);
%     normalizecol = sumkk/nn;
% 
% C5 = corrcoef(sum3);


%[Y,I] = max(H);
%imshow(imadjust(mat2gray(H)),'XData',T,'YData',R,'InitialMagnification', 'fit');
peaks  = houghpeaks(H,2, 'Threshold',20);
lines = houghlines(X,T,R,peaks);


%e = zeros(a,numel(lines));
%f = zeros(a,numel(lines));
%g = zeros(a,numel(lines));
%h = zeros(a,numel(lines));


hold on
for k = 1:numel(lines)
    x1 = lines(k).point1(1);
    y1 = lines(k).point1(2);
    x2 = lines(k).point2(1);
    y2 = lines(k).point2(2);
   %plot([x1 x2],[y1 y2],'Color','g','LineWidth', 1)
    
    m(k) = (y2-y1)/(x2-x1);
    m(a,k) = m(k);
    
    e(k) = x1;
    e(a,k) = e(k);
    f(k) = y1;
    f(a,k) = f(k);
    g(k) = x2;
    g(a,k) = g(k);
    h(k) = y2;
    h(a,k) = h(k);
    
    if 2 < m(a,k) < 40
        G(f(a,k):h(a,k), a) = puf_1(f(a,k):h(a,k), a); 
    end
    
    
end
hold off

end

peaks  = houghpeaks(H1,2, 'Threshold',20);
lines = houghlines(Z,T,R,peaks);


%e = zeros(a,numel(lines));
%f = zeros(a,numel(lines));
%g = zeros(a,numel(lines));
%h = zeros(a,numel(lines));


hold on
for k = 1:numel(lines)
    x1 = lines(k).point1(1);
    y1 = lines(k).point1(2);
    x2 = lines(k).point2(1);
    y2 = lines(k).point2(2);
  %plot([x1 x2],[y1 y2],'Color','g','LineWidth', 1)
    
    m(k) = (y2-y1)/(x2-x1);
    m(a,k) = m(k);
    
    e(k) = x1;
    e(a,k) = e(k);
    f(k) = y1;
    f(a,k) = f(k);
    g(k) = x2;
    g(a,k) = g(k);
    h(k) = y2;
    h(a,k) = h(k);
    
    if 2 < m(a,k) < 40
        G(f(a,k):h(a,k), a+1) = puf_1(f(a,k):h(a,k), a+1); 
    end
    
    
end
hold off


x1t = transpose(e);
y1t = transpose(f);
x2t = transpose(g);
y2t = transpose(h);



G(all(G==0,2),:)=[];
G(G == 0) = 0.1;

C3 = corrcoef(G);
%disp(C2)
J = zeros ((1165:1265),a);

for a = 1:n  

    J(1907:2363, a) = puf_1(1907:2363, a);

end

 J(all(J==0,2),:)=[];
C4 = corrcoef(J);
%disp(C3)

%Calculate lifetimes
puf_1(puf_1 == 0) = 0.1;
%disp(puf_1)
hold on
for a = 1:n
 y =( puf_1(1700:2600,a));
 x = t(1700:2600,1);
 %semilogy(x)
 z = log(y);
 plot(z, x)


d = polyfit(z, x, 1);
s = -1/d(1,1);
disp (s)
%e = polyval(d,x);
%disp(e)
%plot((keep2),x)
end
hold off


%log cross-corr
%C5 = corrcoef(log(puf_1));
%disp(C4)

toc
