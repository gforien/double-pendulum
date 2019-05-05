function Em = Energie(m1, m2, L1, L2, g, X, Xp, ~, nbPasTemps)
    %% ENERGIE Calcule l'�nergie m�canique du pendule au cours du temps
    %   L'�nergie m�canique �tant la somme de l'�nergie cin�tique et potentielle � chaque pas de temps
    %
    %  Re�oit : param�tres du probl�me m1, m2, L1, L2, g, dt, nbPasTemps
    %           X : une matrice de positions d�j� calcul�e
    %           Xp : une matrice de vitesses d�j� calcul�e
    %
    %  Renvoie Em : une matrice de l'�nergie m�canique � chaque pas de temps

    Ec = zeros(1, nbPasTemps);
    Epp = zeros(1, nbPasTemps);
    for i=1:nbPasTemps+1
        Ec(1,i)=1/2*(m1+m2)*L1^2*Xp(1,i)^2 + 1/2*m2*L2^2*Xp(2,i)^2+m2*L1*L2*Xp(1,i)*Xp(2,i)*cos(X(1,i)-X(2,i));
        Epp(1,i)=-(m1+m2)*g*L1*cos(X(1,i))-m2*g*L2*cos(X(2,i));
    end
    
    Em = Ec + Epp;
end