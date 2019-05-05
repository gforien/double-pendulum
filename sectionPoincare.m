function Ps = sectionPoincare(X, Xp, nbPasTemps)
    %% SECTIONPOINCARE Détermine la section de Poincaré du pendule double               
    %   En theta2, lorsque le pendule 1 passe par l'axe vertical x = 0
    %
    %  Reçoit : X : une matrice de positions déjà calculée
    %           Xp : une matrice de vitesses déjà calculée
    %
    %  Renvoie Ps : l'ensemble des points de la section de Poincaré
    
    X = mod(X+pi, 2*pi)-pi;
    p=1;
    for i=1:nbPasTemps
    	%test de croisement de l'axe vertical avec le produit de deux valeurs de ?2 successives
        if(X(1,i)*X(1,i+1)<=0)
            if(Xp(1,i)<0)
                Ps(1, p) = X(2,i);
                Ps(2, p) = Xp(2,i);
                p = p+1;
            end
        end
    end
end