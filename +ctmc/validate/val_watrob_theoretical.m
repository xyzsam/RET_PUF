
%watrob calcs
n0 = 1;

%tw1 = linspace(0,SIM_time_span,n1); tw1 = tw1';
c1t = n0.*exp(-1.*(kr1_knr1+kt12+kt13).*tw1);
%save val_watrob_data c1t tw1 -append; clear c1t tw1;

%tw2 = linspace(0,SIM_time_span,n2); tw2 = tw2';
c2t = (n0.*kt12.*(exp(-1.*(kr1_knr1+kt12+kt13).*tw2)-exp(-1.*(kr2_knr2+kt23).*tw2)))./((kr2_knr2 + kt23)-(kr1_knr1 + kt12 + kt13));
%save val_watrob_data c2t tw2 -append; clear c2t tw2;

%tw3 = linspace(0,SIM_time_span,n3); tw3 = tw3';
aa1 = ((kr3_knr3)-(kr2_knr2+kt23));
aa2 = (kr2_knr2+kt23) - (kr1_knr1+kt12+kt13);
aa3 = (kt12*kt23 + kt13*aa2);
aa = aa1*aa3.*exp(-1*(kr1_knr1+kt12+kt13).*tw3);
bb1 = kt12*kt23*(kr3_knr3 - (kr1_knr1+kt12+kt13));
bb = bb1.*exp(-1*(kr2_knr2+kt23).*tw3);
cc1 = (kr2_knr2+kt23)-(kr1_knr1+kt12+kt13);
cc2 = kt12*kt23 + kt13*kt23 + kt13*kr2_knr2 - kt13*kr3_knr3;
cc = (cc1*cc2).*exp(-1*(kr3_knr3).*tw3);
num3 = n0.*(aa-bb+cc);
dd = (kr3_knr3) - (kr2_knr2+kt23);
ee = (kr3_knr3) - (kr1_knr1+kt12+kt13);
ff = (kr2_knr2+kt23) - (kr1_knr1+kt12+kt13);
den3 = dd*ee*ff;
c3t = num3./den3;
%save val_watrob_data c3t tw3 -append; clear c3t tw3;

