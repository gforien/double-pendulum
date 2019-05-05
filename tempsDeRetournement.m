function graph = tempsDeRetournement(m1, m2, L1, L2, g, dt, nbPasTemps, pas)
    %% TEMPSDERETOURNEMENT Calcule le temps de retournement du pendule en fonction des conditions initiales
    %   Pour un pendule à vitesse initiale nulle.
    %
    %  Reçoit : paramètres du problème m1, m2, L1, L2, g, dt, nbPasTemps
    %           pas : la précision du graphique en °
    %
    %  Renvoie graph : graphique logarithmique du temps de retournement

    theta=0:pas:180;    
    nbIter = numel(theta);
    
    premierQuartile = zeros(nbIter, nbIter);
    deuxiemeQuartile = zeros(nbIter, nbIter);

    pourcent = 0;
    for i=1:nbIter
        for j=1:nbIter
            
            % Pour déterminer la limite uniquement
%             if theta(j) <= 20
%                 premierQuartile(i,j) = dt*nb_iter_t;
%                 deuxiemeQuartile(i,j) = dt*nb_iter_t;
%             end

            X0 = [deg2rad(theta(i)); deg2rad(theta(j))];
            Xp0 = [0; 0];
            premierQuartile(i,j) = NewmarkNewtonRaphsonAdapte(m1, m2, L1, L2, g, X0, Xp0, dt, nbPasTemps);
            fprintf('theta1 = %d; theta2 = %d       -> temps = %d\n', theta(i), theta(j), premierQuartile(i,j));

            if theta(i) == 0 || theta(i) == 180 || theta(j) == 0 || theta(j) == 180
                deuxiemeQuartile(i,j) = premierQuartile(i,j);
            else
                X0 = [deg2rad(-theta(i)); deg2rad(theta(j))];
                Xp0 = [0; 0];
                deuxiemeQuartile(i,j) = NewmarkNewtonRaphsonAdapte(m1, m2, L1, L2, g, X0, Xp0, dt, nbPasTemps);
                fprintf('theta1 = %d; theta2 = %d       -> temps = %d\n', -theta(i), theta(j), deuxiemeQuartile(i,j));
            end
            
            if round(i/nbIter + j/nbIter^2, 2) > pourcent
                pourcent = round(i/nbIter + j/nbIter^2, 2);
                waitbar(pourcent);
            end
        end
    end

    % pour tester le rendu
    % premierQuartile = [ 0 0 0 0; 0 1 1 1; 0 1 2 2; 0 1 2 3];
    % deuxiemeQuartile = [ 0 0 0 0; 0 2 2 2; 0 2 3 3; 0 2 3 4];
    
    % on supprime la colonne theta1 = 0
    deuxiemeQuartile = deuxiemeQuartile(:, 2:nbIter);
    deuxiemeQuartile = fliplr(deuxiemeQuartile);
    
    % on supprime la ligne theta2 = 0
    troisiemeQuartile = premierQuartile(2:nbIter, :);
    quatriemeQuartile = deuxiemeQuartile(2:nbIter, :);
    troisiemeQuartile = fliplr(flipud(troisiemeQuartile)); %#ok<FLUDLR>
    quatriemeQuartile = fliplr(flipud(quatriemeQuartile)); %#ok<FLUDLR>
    graph = [ troisiemeQuartile, quatriemeQuartile; deuxiemeQuartile, premierQuartile];
    graph = log(graph);
end

function tRetournement = NewmarkNewtonRaphsonAdapte(m1, m2, L1, L2, g, X0, Xp0, dt, nb_iter_t)
    %% NEWMARKNEWTONRAPHSONADAPTE Calcule rapidement le temps de retournement dans le cas non-linéraire
    %   Quitte la boucle principale et renvoie le temps de retournement dès qu'il est atteint
    %   Le pendule passe par 3 états : 0 - au-dessus de l'axe horizontal
    %                                  1 - tombé en-dessous de l'axe horizontal
    %                                  2 - remonté au-dessus de l'axe horizontal
    %   C'est seulement lorsque l'état 2 est atteint (estRetourne = 2) qu'on considère qu'il est 'retourné'

    L = polaireVersCartesien(L1, X0(1), L2, X0(2));
    % Selon la position initiale, il est dans l'état 0 ou l'état 1
    if L(4) > 0
        estRetourne = 0;
    else
        estRetourne = 1;
    end
    
    precNR=1.e-11;
    X = zeros(2, nb_iter_t+1);
    Xp = zeros(2, nb_iter_t+1);
    Xpp= zeros(2, nb_iter_t+1);
    
    X(:, 1) = X0;
    Xp(:, 1) = Xp0;
    C = [(m1+m2)*L1  0; 0 m2*L2];
    
    deltaTheta=X0(1)-X0(2);
    M = m1 + m2;
    A = [ M*L1, m2*L2*cos(deltaTheta); m2*L1*cos(deltaTheta), m2*L2];
    B = [ -m2*L2*sin(deltaTheta)*Xp0(2)^2 - M*g*sin(X0(1));
           m2*L1*sin(deltaTheta)*Xp0(1)^2 - m2*g*sin(X0(1))];
    Xpp0 = A\B;
    Xpp(:,1)=Xpp0;

    for n=1:nb_iter_t
        % Prédiction : on calcule les inconnues au rang n+1
        X(:,n+1) = X(:,n) + dt*Xp(:,n) + (dt^2/2)*Xpp(:,n);
        Xp(:,n+1) = Xp(:,n)+dt*Xpp(:,n);
        Xpp(:,n+1) = Xpp(:,n);
        
        % Calcul du résidu censé valoir 0 au rang n+1
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
        
        L(:) = polaireVersCartesien(L1, X(1,n+1), L2, X(2,n+1));
        if estRetourne == 0 && L(4) < 0
            estRetourne = 1;
        elseif estRetourne == 1 && L(4) >= 0
            estRetourne = 2; %#ok<NASGU>
            break;
        end
    end
    tRetournement = n*dt;
end