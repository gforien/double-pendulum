function X = Analytique(m1, m2, L1, L2, g, Y0, dt, nbPasTemps)
    %% ANALYTIQUE Calcule la solution analytique aux équations linéaires du pendule double
    %   En fonction des paramètres du problème, et des conditions initiales
    %
    %  Reçoit : paramètres du problème m1, m2, L1, L2, g, dt, nbPasTemps
    %           Y0 : conditions initiales de la forme (theta1, thetaPoint1, theta2, thetaPoint2)
    %
    %  Renvoie X : positions du pendule au cours du temps, de la forme (theta1, theta2)

    mu=m2/m1;
    theta1Rad0=Y0(1);
    dtheta10=Y0(2);
    theta2Rad0=Y0(3);
    dtheta20=Y0(4);

    w1sq=(g*(1+mu)*(L1+L2)+g*sqrt((1+mu)^2*(L1+L2)^2-4*(1+mu)*L1*L2))/(2*L1*L2);
    w2sq=(g*(1+mu)*(L1+L2)-g*sqrt((1+mu)^2*(L1+L2)^2-4*(1+mu)*L1*L2))/(2*L1*L2);
    A1=(1+mu)/mu-L1/(mu*g)*w1sq;
    A2=(1+mu)/mu-L1/(mu*g)*w2sq;

    C1=(theta2Rad0-A2*theta1Rad0)/(A1-A2);
    C2=(A1*theta1Rad0-theta2Rad0)/(A1-A2);
    sinphi1=(dtheta20-A2*dtheta10)/(C1*sqrt(abs(w1sq))*(A2-A1));
    sinphi2=(A1*dtheta10-dtheta20)/(C2*sqrt(abs(w2sq))*(A2-A1));
    phi1=asin(sinphi1);
    phi2=asin(sinphi2);

    X=zeros(2, nbPasTemps+1);
    X(:, 1)=[theta1Rad0 theta2Rad0];
    for n=2:1:nbPasTemps+1
        X(1, n)=C1*cos(sqrt(abs(w1sq))*(n-1)*dt+phi1)+C2*cos(sqrt(abs(w2sq))*(n-1)*dt+phi2);
        X(2, n)=C1*A1*cos(sqrt(abs(w1sq))*(n-1)*dt+phi1)+C2*A2*cos(sqrt(abs(w2sq))*(n-1)*dt+phi2);
    end
end