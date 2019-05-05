function graph = limiteDeLaPeriodicite(m1, m2, L1, L2, g, dt, nb_iter_t, pas)
%% limiteDeLaPeriodicite
%
%   Tests : temps total = 50 sec; précision = 9° ---> temps de calcul = 1h (3879 sec)
%                                                     temps moyen d'une opération = 8.80 sec 

    theta=0:pas:180;    
    nbIter = numel(theta);
    
    premierQuartile = zeros(nbIter, nbIter);
    deuxiemeQuartile = zeros(nbIter, nbIter);

    pourcent = 0;
    for i=1:nbIter
        for j=1:nbIter
            theta1=deg2rad(theta(i));
            theta2=deg2rad(theta(j));

            % Pour déterminer la limite uniquement
%             if theta(j) >= 120
%                 premierQuartile(i,j) = 100;
%                 deuxiemeQuartile(i,j) = 100;
%                 continue
%             end
%             if theta(i) + theta(j) <= 100
%                 premierQuartile(i,j) = 0;
%                 deuxiemeQuartile(i,j) = 0;
%                 continue
%             end
            
            X0 = [theta1; theta2];
            X0_2 = [theta1 + deg2rad(0.1); theta2];
            Xp0 = [0; 0];
            [X, ~] = NewmarkNewtonRaphson(m1, m2, L1, L2, g, X0, Xp0, dt, nb_iter_t, 0);
            [X_2, ~] = NewmarkNewtonRaphson(m1, m2, L1, L2, g, X0_2, Xp0, dt, nb_iter_t, 0);
            % calcul de l'erreur
            M = max(abs(X), [], 2);
            erreurRelative = 100*abs(X - X_2)./M;
            premierQuartile(i,j) = max(mean(erreurRelative, 2));
            if premierQuartile(i,j) == Inf
                    premierQuartile(i,j) = 0;
            end
            %fprintf('theta1 = %d; theta2 = %d       -> erreur = %d\n', theta(i), theta(j), premierQuartile(i,j));

            if theta1 == 0 || theta1 == pi || theta2 == 0 || theta2 == pi
                deuxiemeQuartile(i,j) = premierQuartile(i,j);
            else
                X0 = [-theta1; theta2];
                X0_2 = [-theta1 - deg2rad(0.1); theta2];
                Xp0 = [0; 0];
                [X, ~] = NewmarkNewtonRaphson(m1, m2, L1, L2, g, X0, Xp0, dt, nb_iter_t, 0);
                [X_2, ~] = NewmarkNewtonRaphson(m1, m2, L1, L2, g, X0_2, Xp0, dt, nb_iter_t, 0);
                % calcul de l'erreur
                M = max(abs(X), [], 2);
                erreurRelative = 100*abs(X - X_2)./M;
                deuxiemeQuartile(i,j) = max(mean(erreurRelative, 2));
                if deuxiemeQuartile(i,j) == Inf
                    deuxiemeQuartile(i,j) = 0;
                end
                %fprintf('theta1 = %d; theta2 = %d       -> erreur = %d\n', -theta(i), theta(j), deuxiemeQuartile(i,j));
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
end