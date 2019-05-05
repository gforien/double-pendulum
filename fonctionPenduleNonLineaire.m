function dYdt = fonctionPenduleNonLineaire(m1, m2, L1, L2, g, Y)
    %% FONCTIONPENDULENONLINEAIRE Calcule dY(t)/dt à partir de Y(t) par les équations non-linéaires du mouvement
    %
    %  Reçoit : Y(t) : les coordonnées du pendule au temps t, de la forme (theta1, thetaPoint1, theta2, thetaPoint2)
    %
    %  Renvoie : dY(t)/dt : l'accroissement de ces coordonnées temps t,
    %                       de la forme (theta1, thetaPoint1, theta2, thetaPoint2)

    thetapp13=(-m2*cos(Y(1)-Y(3))*(L1*sin(Y(1)-Y(3))*Y(2)^2-g*sin(Y(3)))-m2*L2*sin(Y(1)-Y(3))*Y(4)^2-(m1+m2)*g*sin(Y(1)))/((m1+m2)*L1-m2*cos(Y(1)-Y(3))*L1*cos(Y(1)-Y(3)));
    thetapp23=(1/L2)*(-L1*cos(Y(1)-Y(3))*thetapp13+L1*sin(Y(1)-Y(3))*Y(2)^2-g*sin(Y(3)));

    dYdt=zeros(4,1);    
    dYdt(1)=Y(2);
    dYdt(2)=thetapp13;
    dYdt(3)=Y(4);
    dYdt(4)=thetapp23;
end