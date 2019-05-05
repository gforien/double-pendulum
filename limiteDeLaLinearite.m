function graph = limiteDeLaLinearite(m1, m2, L1, L2, g, dt, nb_iter_t, pas)
%% limiteDeLaLinearite

    axe=0:pas:180;    
    nbIter = numel(axe);
    partieDroite = zeros(1, nbIter);

    pourcent = 0;
    for i=1:nbIter
        theta=deg2rad(axe(i));
        
        % conditions initiales
        Y0 = [ theta; 0; theta; 0];
        X0 = [ theta; theta];
        Xp0 = [0; 0];
        % calcul des 2 solutions
        X_Lin = Analytique(m1, m2, L1, L2, Y0, dt, nb_iter_t);
        [X_NonLin, ~] = NewmarkNewtonRaphson(m1, m2, L1, L2, g, X0, Xp0, dt, nb_iter_t, 0);
        
        % calcul de l'erreur
        M = max(abs(X_Lin), [], 2);
        erreurRelative = 100*abs(X_Lin - X_NonLin)./M;
        partieDroite(i) = max(mean(erreurRelative, 2));
        if partieDroite(i) == Inf || isnan(partieDroite(i))
                partieDroite(i) = 0;
        end
        fprintf('theta1 = %d; theta2 = %d       -> erreur = %d\n', axe(i), axe(i), partieDroite(i));

        if round(i/nbIter, 2) > pourcent
            pourcent = round(i/nbIter, 2);
            waitbar(pourcent);
        end
    end
    
    % on supprime la colonne theta1 = 0, et on crée le symétrique du graphe
    partieGauche = partieDroite(2:nbIter);
    partieGauche = fliplr(partieGauche);
    graph = [ partieGauche, partieDroite ];
end