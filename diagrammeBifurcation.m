function Bf = diagrammeBifurcation(m1, m2, L1, L2, g, dt, nbPasTemps, pas)
    %% DIAGRAMMEBIFURCATION Détermine le diagramme de bifurcation du pendule double
    %   Avec la résolution des équations non-linéaires par Newmark Newton-Raphson
    %   De même que pour la section de Poincaré : en theta2, lorsque le pendule 1 passe par l'axe vertical x = 0
    %
    %  Reçoit : paramètres du problème m1, m2, L1, L2, g, dt, nbPasTemps
    %           pas : la précision du graphique (en °)
    %
    %  Renvoie Bf : l'ensemble des points du diagramme de bifurcation

    theta = 0:pas:180;
    nbIter = numel(theta);
    Xp0 = [0; 0];
    
    pourcent = 0;
    for i=1:nbIter
        X0 = [deg2rad(theta(i)); deg2rad(theta(i))];
        [Xraph, dXraph] = NewmarkNewtonRaphson(m1, m2, L1, L2, g, X0, Xp0, dt, nbPasTemps, 0);
        Xraph = mod(Xraph+pi, 2*pi)-pi;

        q=2;
        for j=1:1:nbPasTemps
            %test de croisement de l'axe vertical avec le produit de deux valeurs de theta2 successives
            if(Xraph(1,j)*Xraph(1,j+1)<=0)
                if(dXraph(1,j)<0)
                    Bf(1,i)=theta(i);
                    Bf(q,i)=dXraph(2,j);
                    q=q+1;
                end
            end
        end
        
        if round(i/nbIter) > pourcent
            pourcent = round(i/nbIter, 2);
            waitbar(pourcent);
        end
    end
end