function Y = Verlet(dt,nb_iter_t, Y0, m1, m2, L1, L2, g)
    %% VERLET Calcule la solution aux équations linéaires du pendule double par le schéma numérique de Verlet
    %   En fonction des paramètres du problème, et des conditions initiales
    %
    %  Reçoit : paramètres du problème m1, m2, L1, L2, g, dt, nbPasTemps
    %           Y0 : conditions initiales de la forme (theta1, thetaPoint1, theta2, thetaPoint2)
    %
    %  Renvoie Y : positions du pendule au cours du temps, de la forme (theta1, thetaPoint1, theta2, thetaPoint2)

    mu=m2/m1;
    Y = zeros(4, nb_iter_t+1);
    Y(:, 1) = Y0;

    for i=1:nb_iter_t
      Y(1,i+1)= Y(1,i)+dt*Y(2,i)+(dt^2/2)*(1/L1)*(-(1+mu)*g*Y(1,i)+mu*g*Y(3,i));
      Y(3,i+1)= Y(3,i)+dt*Y(4,i)+(dt^2/2)*(1/L2)*((1+mu)*g*Y(1,i)-(1+mu)*g*Y(3,i));
      Y(2,i+1)= Y(2,i)+(dt/2)*(1/L1)*(-(1+mu)*g*(Y(1,i)+Y(1,i+1))+mu*g*(Y(3,i)+Y(3,i+1)));
      Y(4,i+1)= Y(4,i)+(dt/2)*(1/L2)*((1+mu)*g*(Y(1,i)+Y(1,i+1))-(1+mu)*g*(Y(3,i)+Y(3,i+1)));
    end
end