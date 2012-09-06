import hough.getHough;

numExponents = 2;
figure('Color',[1 1 1]);
if (numExponents == 1)
    sub1 = subplot(2,1,1);
else
    sub1 = subplot(2,2,1);
end
surf((1./((tand(90.-T))./dx)).*factor*1e9,R,H,H);
a1 = axis; axis([-1 6 a1(3:4)]); view(sub1,[0 0]);
title('Original','FontSize',18);
xlabel('Lifetime (ns)','FontSize',14); ylabel('Rho','FontSize',14); zlabel('Hough Magnitude','FontSize',14);


aax = x;
% synTau1 = 1.67e-9;
% synTau2 = 1.67e-9;
aay1 = exp(-aax./synTau1);
aay2 = exp(-aax./synTau2);
aay3 = aay1.*aay2;
[H1 T1 R1 factor1 peakTaus1] = getHough(aax,aay1,dx,pks);
[H2 T2 R2 factor2 peakTaus2] = getHough(aax,aay2,dx,pks);
[H3 T3 R3 factor3 peakTaus3] = getHough(aax,aay3,dx,pks);

if (numExponents == 1)
    sub2 = subplot(2,1,2);
    surf((1./((tand(90.-T1))./dx)).*factor*1e9,R1,H1,H1);
    a2 = axis; axis([-1 6 a2(3:4)]); view(sub2,[0 0]);
    title(['Synthetic: Tau = ' num2str(synTau1*1e9,2)],'FontSize',18);
    xlabel('Lifetime (ns)','FontSize',14); ylabel('Rho','FontSize',14); zlabel('Hough Magnitude','FontSize',14);
else
    sub2 = subplot(2,2,2);
    surf((1./((tand(90.-T3))./dx)).*factor*1e9,R3,H3,H3);
    a2 = axis; axis([-1 6 a2(3:4)]); view(sub2,[0 0]);
    newTau = 1e9/((synTau1+synTau2)/(synTau1*synTau2));
    title(['Synthetic Combined: Tau = ' num2str(newTau,2)],'FontSize',18);
    xlabel('Lifetime (ns)','FontSize',14); ylabel('Rho','FontSize',14); zlabel('Hough Magnitude','FontSize',14);
end


if (numExponents > 1)
    
    sub3 = subplot(2,2,3);
    surf((1./((tand(90.-T2))./dx)).*factor*1e9,R1,H1,H1);
    a3 = axis; axis([-1 6 a3(3:4)]); view(sub3,[0 0]);
    title(['Synthetic 1: Tau = ' num2str(synTau1*1e9,2)],'FontSize',18);
    xlabel('Lifetime (ns)','FontSize',14); ylabel('Rho','FontSize',14); zlabel('Hough Magnitude','FontSize',14);
    
    sub4 = subplot(2,2,4);
    surf((1./((tand(90.-T3))./dx)).*factor*1e9,R2,H2,H2);
    a4 = axis; axis([-1 6 a4(3:4)]); view(sub4,[0 0]);
    title(['Synthetic 2: Tau = ' num2str(synTau2*1e9,2)],'FontSize',18);
    xlabel('Lifetime (ns)','FontSize',14); ylabel('Rho','FontSize',14); zlabel('Hough Magnitude','FontSize',14);
    
end