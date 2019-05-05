function [X, Xp]=NewmarkNewtonRaphson(m1, m2, L1, L2, g, X0, Xp0, dt, nbPasTemps, afficherBarre)
    %% NEWMARKNEWTONRAPHSON Calcule la solution aux équations non-linéaires du pendule double
    %   Par le schéma numérique de Newmark + itérations de Newton-Raphson pour résoudre à chaque pas de temps l'équation
    %   -C * Xpp - Fnl = 0
    %
    %   Reçoit les paramètres du problème (m1, m2, L1, L2, g, dt, nbPasTemps)
    %            X0 : position initiale, de la forme (theta1, theta2)
    %            Xp0 : vitesse initiale, de la forme (thetaPoint1, thetaPoint2)
    %            afficherBarre : booléen, pour afficher ou non la barre de chargement graphique
    %
    %   Renvoie X : positions du pendule au cours du temps, de la forme (theta1, theta2)
    %           Xp : vitesses du pendule au cours du temps, de la forme (thetaPoint1, thetaPoint2)


    % Précision sur la solution de Newton-Raphson
    precNR=1.e-11;
    
    % Initialisation des matrices de position, vitesse, accélération
    X = zeros(2, nbPasTemps+1);
    Xp = zeros(2, nbPasTemps+1);
    Xpp= zeros(2, nbPasTemps+1);
    X(:, 1) = X0;
    Xp(:, 1) = Xp0;
    
    % On résoud le système au temps t=0 pour obtenir l'accélération initiale
    deltaTheta=X0(1)-X0(2);
    M = m1 + m2;
    A = [ M*L1, m2*L2*cos(deltaTheta); m2*L1*cos(deltaTheta), m2*L2];
    B = [ -m2*L2*sin(deltaTheta)*Xp0(2)^2 - M*g*sin(X0(1));
           m2*L1*sin(deltaTheta)*Xp0(1)^2 - m2*g*sin(X0(1))];
    Xpp0 = A\B;
    Xpp(:,1)=Xpp0;

    % Matrice C des coefficients devant les termes d'accélération
    % Tous les autres termes des équations non-linéaires sont compris dans Fnl
    C = [(m1+m2)*L1  0; 0 m2*L2];
    
    pourcent = 0;
    for n=1:nbPasTemps
        % Prédiction : on calcule les inconnues au rang n+1
        X(:,n+1) = X(:,n) + dt*Xp(:,n) + (dt^2/2)*Xpp(:,n);
        Xp(:,n+1) = Xp(:,n)+dt*Xpp(:,n);
        Xpp(:,n+1) = Xpp(:,n);
        
        % Calcul du résidu censé être nul au rang n+1
        deltaTheta = X(1,n+1) - X(2,n+1);
        Fnl = zeros(2,1);
        Fnl(1)= m2*L2*cos(deltaTheta)*Xpp(2,n+1) + m2*L2*sin(deltaTheta)*Xp(2,n+1)^2 + M*g*sin(X(1,n+1));
        Fnl(2)= m2*L1*cos(deltaTheta)*Xpp(1,n+1) - m2*L1*sin(deltaTheta)*Xp(1,n+1)^2 + m2*g*sin(X(2,n+1));
        residu = -C*Xpp(:,n+1)-Fnl;
        
        % Itérations de Newton-Raphson sur les inconnues au rang n+1 jusqu'à ce que le résidu soit nul
        nbIter=0;
        while (norm(residu)>precNR) && nbIter <= 1e3
            nbIter=nbIter+1;
            
            % Calcul de la Jacobienne
            deltaTheta = X(1,n+1) - X(2,n+1);
            Jx = zeros(2,2);
            Jx(1,1) = M*g*cos(X(1,n+1)) + m2*L2*(cos(deltaTheta)*Xp(2,n+1)^2 -sin(deltaTheta)*Xpp(2,n+1));
            Jx(1, 2) = m2*L2*(sin(deltaTheta)*Xpp(2,n+1) - cos(deltaTheta)*Xp(2,n+1)^2);
            Jx(2, 1) = -m2*L1*(sin(deltaTheta)*Xpp(1,n+1) - cos(deltaTheta)*Xp(1,n+1)^2);
            Jx(2, 2) = m2*L1*(sin(deltaTheta)*Xpp(1,n+1) + cos(deltaTheta)*Xp(1,n+1)^2) + m2*g*cos(X(2,n+1));

            Jxp = zeros(2,2);
            Jxp(1, 2) = 2*m2*L2*sin(deltaTheta)*Xp(2,n+1);
            Jxp(2, 1) = -2*m2*L1*sin(deltaTheta)*Xp(1,n+1);
            
            J=(4/dt^2)*(C)+(2/dt)*(Jxp)+Jx;
            
            % Calcul des inconnues corrigées
            deltaX=J\residu;
            X(:,n+1)=X(:,n+1)+deltaX;
            Xp(:,n+1)=Xp(:,n+1)+(2/dt)*deltaX;
            Xpp(:,n+1)=Xpp(:,n+1)+(4/dt^2)*deltaX;
            
            % Re-calcul du résidu censé valoir 0
            deltaTheta = X(1,n+1) - X(2,n+1);
            Fnl = zeros(2,1);
            Fnl(1)= m2*L2*cos(deltaTheta)*Xpp(2,n+1) + m2*L2*sin(deltaTheta)*Xp(2,n+1)^2 + M*g*sin(X(1,n+1));
            Fnl(2)= m2*L1*cos(deltaTheta)*Xpp(1,n+1) - m2*L1*sin(deltaTheta)*Xp(1,n+1)^2 + m2*g*sin(X(2,n+1));
            residu = -C*Xpp(:,n+1)-Fnl;
        end
        % Affichage sympathique du pourcentage, pour savoir où on en est
        if round(n/nbPasTemps, 2) > pourcent && afficherBarre
            pourcent = round(n/nbPasTemps, 2);
            waitbar(pourcent);
        end
    end
end