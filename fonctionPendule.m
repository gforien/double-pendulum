function dYdt = fonctionPendule(m1, m2, L1, L2, g, Y)
    %% FONCTIONPENDULE Calcule dY(t)/dt � partir de Y(t) par les �quations lin�aire du mouvement
    %
    %  Re�oit : Y(t) : les coordonn�es du pendule au temps t, de la forme (theta1, thetaPoint1, theta2, thetaPoint2)
    %
    %  Renvoie : dY(t)/dt : l'accroissement de ces coordonn�es temps t,
    %                       de la forme (theta1, thetaPoint1, theta2, thetaPoint2)

    mu=m1/m2;
    dYdt=zeros(4,1);

    dYdt(1)=Y(2);
    dYdt(2)=((mu*g*Y(3))-(1+mu)*g*Y(1))/L1;
    dYdt(3)=Y(4);
    dYdt(4)=((1+mu)*g*Y(1)-(1+mu)*g*Y(3))/L2;
end
