function Pos = polaireVersCartesien(L1, theta1, L2, theta2)
    %% POLAIRE_VERS_CARTESIEN Effectue le changement de variable polaire -> cartésien pour le pendule double
    %   A ne pas confondre avec un changement de variable classique
    %
    %   Recoit  L1 : la longueur de la tige 1
    %           theta1 : une matrice de theta1 en fonction du temps
    %           L2 : la longueur de la tige 2
    %           theta1 : une matrice de theta2 en fonction du temps
    %
    %   Renvoie Pos : matrice des coordonées cartésiennes du pendule en fonction du temps,
    %                 de la forme (x1, y1, x2, y2)

    Pos = zeros(4, length(theta1));
    Pos(1, :) = L1.*sin(theta1);
    Pos(2, :) = -L1.*cos(theta1);
    Pos(3, :) = L1.*sin(theta1) + L2.*sin(theta2);
    Pos(4, :) = -L1.*cos(theta1) - L2.*cos(theta2);
end

