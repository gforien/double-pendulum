function PenduleDouble()
    %% PENDULEDOUBLE : Lance la fen�tre principale du programme
    %   Initialise les variables du probl�me, cr�e l'interface graphique et la lance
    %   Le programme est ensuite dans la boucle principale de l'interface graphique,
    %   en attente d'une acition de l'utilisateur
    %
    %   On calcule les positions et vitesses des masses du pendule double, sous diff�rentes formes
    %   selon les �quations que l'on utilise dans chaque partie du programme. Pour clarifier ces variables,
    %   on a adopt� la m�me convention de nommage des variables dans TOUS les fichiers du programme :
    %       Y : vecteur inconnu en coordonn�es polaires utilis� dans les �quations de type dY/dt = F(Y,t)
    %       Y = (theta1, thetaPoint1, theta2, thetaPoint2)
    %
    %       X : vecteur inconnu en coordonn�es polaires utilis� dans les autres �quations
    %       X = (theta1, theta2)
    %       Xp = (thetaPoint1, thetaPoint2)
    %       Xpp = X = (thetaPointPoint1, thetaPointPoint2)
    %
    %       Pos : vecteur de la position en coordonn�es cart�siennes
    %       Pos = (x1, y1, x2, y2)
    %
    %   Pierre-Adrien Millot; Mariem Ksouri; Agathe Menon; R�mi Bacot; Gabriel Forien
    %   INSA Lyon - 2018  

    % Param�tres de l'animation
    close all;
    global gJouer gPasDeTemps gPause gTrace;
    gJouer = 1;
    gPause = 0;
    gPasDeTemps = 6;
    gTrace = 0;
    
    % Param�tres du probl�me
    m1 = 2;                                         % masse 1                   (kg)
    m2 = 3;                                         % masse 2                   (kg)
    L1 = 3;                                         % longueur de la tige 1     (m)
    L2 = 2;                                         % longueur de la tige 2     (m)
    g = 9.81;                                       % pesanteur                 (m.s-2)
    dt = 5e-3;                                      % pas de temps              (s)
    nbPasTemps = 1e4;                               % nombre de pas de temps
    
    % Conditions initiales
    theta10_DEG = 70;
    theta20_DEG = 20;
    dtheta10_DEG=0;
    dtheta20_DEG=0;

    % Cr�ation de l'IHM
    fenetre = figure('Name', 'P2I7 : Pendule Double', 'NumberTitle', 'off',...
        'position', [250 70 1000 600], 'Resize', 'off', 'Visible', 'On',...
        'MenuBar', 'none', 'ToolBar', 'none', 'WindowKeyPressFcn', @entreeClavier);

    % panneaux et zones principales
    axes('Parent', fenetre, 'Position', [0.035 0.04 0.64 0.94], 'Tag', 'dessin');
    panneauLateral = uipanel('Parent', fenetre, 'Position', [0.67 0 0.33 1]);
    panneauSelection = uipanel(panneauLateral, 'Title', 'Action', 'Position',  [0 0.75 1 0.25]);
    parametres = uipanel(panneauLateral, 'Title', 'Param�tres', 'Position', [0 0.1 1 0.65]);
    controles =  uipanel(panneauLateral, 'Title', 'Contr�les', 'Position', [0 0   1 0.1]);

    % listbox pour s�lectionner l'action � ex�cuter
    uicontrol(panneauSelection, 'style', 'listbox', 'Position', [ 5 5 315 125 ], 'Tag', 'selection', 'fontsize', 10,...
        'Max', 1, 'Min', 1, 'callback', @actualiser, 'string',...
        {'R�solution des �quations lin�aires (ODE45)';...
        'R�solution des �quations lin�aires (Verlet)';...
        'Solution analytique des �quations lin�aires';...
        'R�solution des �quations non-lin�aires (NNR)';...
        'R�solution des �quations non-lin�aires (ODE45)';...
        'R�solution des �quations non-lin�aires x2';...
        'R�solution des �quations lin�aires + non-lin�aires';...
        'Energie du pendule au cours du temps';...
        ['Portaits de phase, section de Poincar� en ', char(952) '2'];...
        '(Graphique) Diagramme de bifurcation';...
        '(Graphique) Temps de retournement';...
        '(Graphique) Limite de la lin�arit�';...
        '(Graphique) Limite de la p�riodicit�';});

    % libell�s de champs de param�tres
    uicontrol(parametres, 'style', 'text', 'position', [ 5 330 170 30 ], 'string', ['Angle initial ' char(952) '1 (en �)'], 'fontsize', 11, 'HorizontalAlignment', 'left');
    uicontrol(parametres, 'style', 'text', 'position', [ 5 290 170 30 ], 'string', ['Angle initial ' char(952) '2 (en �)'], 'fontsize', 11, 'HorizontalAlignment', 'left');
    uicontrol(parametres, 'style', 'text', 'position', [ 5 250 170 30 ], 'string', ['Vitesse initiale ' char(952) '1 (en �/s)'], 'fontsize', 11, 'HorizontalAlignment', 'left');
    uicontrol(parametres, 'style', 'text', 'position', [ 5 210 170 30 ], 'string', ['Vitesse initiale ' char(952) '2 (en �/s)'], 'fontsize', 11, 'HorizontalAlignment', 'left');
    uicontrol(parametres, 'style', 'text', 'position', [ 5 170 170 30 ], 'string', 'Masse m1 (en kg)', 'fontsize', 11, 'HorizontalAlignment', 'left');
    uicontrol(parametres, 'style', 'text', 'position', [ 5 130 170 30 ], 'string', 'Masse m2 (en kg)', 'fontsize', 11, 'HorizontalAlignment', 'left');
    uicontrol(parametres, 'style', 'text', 'position', [ 5 90 170 30 ], 'string', 'Longueur L1 (en m)', 'fontsize', 11, 'HorizontalAlignment', 'left');
    uicontrol(parametres, 'style', 'text', 'position', [ 5 50 170 30 ], 'string', 'Longueur L2 (en m)', 'fontsize', 11, 'HorizontalAlignment', 'left');
    uicontrol(parametres, 'style', 'text', 'position', [ 5 10 210 30 ], 'string', 'Pr�cision des graphiques (en �)', 'fontsize', 11, 'HorizontalAlignment', 'left');

    % champs pour modifier les param�tres du probl�me
    uicontrol(parametres, 'style', 'edit', 'position', [ 180 337 100 30 ], 'tag', 'editTheta1', 'string', theta10_DEG, 'fontsize', 11, 'callback', @champDoubleModifie);
    uicontrol(parametres, 'style', 'edit', 'position', [ 180 297 100 30 ], 'tag', 'editTheta2', 'string', theta20_DEG, 'fontsize', 11, 'callback', @champDoubleModifie);
    uicontrol(parametres, 'style', 'edit', 'position', [ 180 257 100 30 ], 'tag', 'editDTheta1', 'string', dtheta10_DEG, 'fontsize', 11, 'callback', @champDoubleModifie);
    uicontrol(parametres, 'style', 'edit', 'position', [ 180 217 100 30 ], 'tag', 'editDTheta2', 'string', dtheta20_DEG, 'fontsize', 11, 'callback', @champDoubleModifie);
    uicontrol(parametres, 'style', 'edit', 'position', [ 180 177 100 30 ], 'tag', 'editM1', 'string', m1, 'fontsize', 11, 'callback', @champDoubleModifie);
    uicontrol(parametres, 'style', 'edit', 'position', [ 180 137 100 30 ], 'tag', 'editM2', 'string', m2, 'fontsize', 11, 'callback', @champDoubleModifie);
    uicontrol(parametres, 'style', 'edit', 'position', [ 180  97 100 30 ], 'tag', 'editL1', 'string', L1, 'fontsize', 11, 'callback', @champDoubleModifie);
    uicontrol(parametres, 'style', 'edit', 'position', [ 180  57 100 30 ], 'tag', 'editL2', 'string', L2, 'fontsize', 11, 'callback', @champDoubleModifie);
    uicontrol(parametres, 'style', 'edit', 'position', [ 220  17 60 30 ], 'tag', 'editPas', 'string', L2, 'fontsize', 11, 'callback', @champDoubleModifie);

    % champs cach�s (uniquement pour stocker les variables g, dt, et nbPasTemps
    uicontrol(parametres, 'style', 'edit', 'Visible', 'off', 'tag', 'editG', 'string', g);
    uicontrol(parametres, 'style', 'edit', 'Visible', 'off', 'tag', 'editDt', 'string', dt);
    uicontrol(parametres, 'style', 'edit', 'Visible', 'off', 'tag', 'editNb_iter_t', 'string', nbPasTemps);

    % boutons pour contr�ler l'animation
    uicontrol(controles, 'style', 'pushbutton', 'Tag', 'boutonRalentir', 'String', '<<', 'Position', [ 10 10 30 30 ], 'callback', @gererAnimation);
    uicontrol(controles, 'style', 'pushbutton', 'Tag', 'boutonLancer',  'String', 'Calcul', 'Position', [ 45 10 50 30 ], 'callback', @lancer);
    uicontrol(controles, 'style', 'pushbutton', 'Tag', 'boutonPause', 'String', 'Play/Pause', 'Position', [ 100 10 70 30 ], 'callback', @gererAnimation);
    uicontrol(controles, 'style', 'pushbutton', 'Tag', 'boutonAccelerer', 'String', '>>', 'Position', [ 175 10 30 30 ], 'callback', @gererAnimation);
    uicontrol(controles, 'style', 'pushbutton', 'Tag', 'boutonActualiser', 'String', 'Reset', 'Position', [ 230 10 50 30 ], 'callback', @actualiser);

    % LAISSER CETTE INSTRUCTION EN DERNIER : stockage des �lements de l'IHM
    guidata(fenetre,guihandles(fenetre));
    actualiser(fenetre);
end

function champDoubleModifie(elementGraphique, ~)
    %%  CHAMPDOUBLEMODIFIE : Verifie que les valeurs entr�es dans les champs de param�tres sont pertinentes
    %   Pour tous les champs, on v�rifie simplement qu'on peut caster la cha�ne de caract�res en double.
    %   Pour le champs editPas qui d�termine la pr�cision des graphiques, on  v�rifie que le pas est un diviseur de 180�
    %
    %   Fonction CALLBACK (appel�e automatiquement lorsque l'utilisateur interagit avec l'interface graphique)
    %   Re�oit  elementGraphique : l'�lement del l'IHM concern� (un bouton, un champ)
    %           evenementGraphique : l'interaction en question (un clic, un appui de touche)
    %   Retourne 0

    % Si la valeur entr�e n'est pas un nombre flottant, on la r�initialise � 0
    if isnan(str2double(get(elementGraphique, 'String')))
        set(elementGraphique, 'String', '0');
    end
    
    % Uniquement pour le champs editPas, qui g�re la pr�cision des graphiques
    if strcmp(get(elementGraphique, 'Tag'),'editPas')
        pas = str2double(get(elementGraphique, 'String'));
        
        % Si la relation n'est pas v�rifi�e, on affiche un message explicatif
        if mod(180, pas) ~= 0
            message = sprintf(['La pr�cision des graphiques (en �), c''est-�-dire le PAS, n''est pas � choisir au hasard.\n',...
                'La relation mod(180, PAS) = 0 doit �tre v�rifi�e\n',...
                'PAS doit donc appartenir aux valeurs suivantes:\n',...
                '1 2 3 4 5 6 9 10 12 15 18 20 30 36 45 60 90 180']);
            boite = msgbox(message,'Pr�cision des graphiques (en �)', 'help', 'Modal');
            boiteHandle = findall(boite);
            set(boiteHandle(1), 'Position', [350 250 350 100]);
            set(boiteHandle(6), 'FontSize', 10);
            uiwait(boite);
        end
        
        % Le pas doit �videmment �tre < 180
        if pas >= 180
            set(elementGraphique, 'String', '1');
        end
        
        % On incr�mente le pas jusqu'� ce que 180 en soit un multiple
        while mod(180, pas) ~= 0
            set(elementGraphique, 'String', num2str(round(pas+1)));
            pas = str2double(get(elementGraphique, 'String'));
        end
    end
    
    actualiser(elementGraphique);
end

function entreeClavier(elementGraphique, evenementGraphique)
    %%  ENTREECLAVIER : Permet � l'utilisateur d'interagir par son clavier
    %   G�n�re des �v�nements sur les boutons lorsque l'utilisateur utilise les touches du clavier
    %
    %   Fonction CALLBACK (appel�e automatiquement lorsque l'utilisateur interagit avec l'interface graphique)
    %   Re�oit  elementGraphique : l'�lement del l'IHM concern� (un bouton, un champ)
    %           evenementGraphique : l'interaction en question (un clic, un appui de touche)
    %   Retourne 0

    fenetre = guidata(elementGraphique);
    global gJouer;
    switch evenementGraphique.Key
        case 'escape'                                   % ESC           -> ferme la fen�tre
            close all;
        case 'return'                                   % ENTREE        -> valide le param�tre entr�
            uicontrol(fenetre.boutonActualiser);
            actualiser(elementGraphique);
        case 'space'                                    % ESPACE        -> joue l'animation / pause l'animation
            uicontrol(fenetre.boutonPause);
            gererAnimation(fenetre.boutonPause);
        case 'leftarrow'                                % FLECHE GAUCHE -> ralentit l'animation
            if gJouer == 1                              % Uniquement si l'animation est en cours, sinon cela g�ne la saisie
                uicontrol(fenetre.boutonRalentir);
                gererAnimation(fenetre.boutonRalentir);
            end
        case 'rightarrow'                               % FLECHE DROITE -> acc�l�re l'animation
            if gJouer == 1                              % Uniquement si l'animation est en cours, sinon cela g�ne la saisie
                uicontrol(fenetre.boutonAccelerer);
                gererAnimation(fenetre.boutonAccelerer);
            end
    end
end

function gererAnimation(elementGraphique, ~)
    %%  GERERANIMATION : G�re les pauses et la vitesse de l'animation par les variables globales
    %
    %   Fonction CALLBACK (appel�e automatiquement lorsque l'utilisateur interagit avec l'interface graphique)
    %   Re�oit  elementGraphique : l'�lement del l'IHM concern� (un bouton, un champ)
    %           evenementGraphique : l'interaction en question (un clic, un appui de touche)
    %   Retourne 0
    
    global gPause gPasDeTemps;
    
    % Pour que le changement du pas de temps soit visible � l'�cran, il faut le faire en �chelle logarithmique
    ordreDeGrandeur = round(log10(gPasDeTemps));

    switch get(elementGraphique, 'Tag')
        case 'boutonPause'          % on inverse simplement le bool�en
            gPause = (gPause == 0);
        case 'boutonAccelerer'      % on augmente d'un ordre de grandeur
            gPasDeTemps = gPasDeTemps + 10^(ordreDeGrandeur - 1);
        case 'boutonRalentir'       % on diminue d'un ordre de grandeur
            gPasDeTemps = gPasDeTemps - 10^(ordreDeGrandeur - 1);
    end
end

function actualiser(elementGraphique, ~)
    %%  ACTUALISER : Met � jour la figure lorsque les param�tres sont modifi�s
    %   R�cup�re les donn�es entr�es dans les champs de param�tres
    %   Calcule la nouvelle position du pendule
    %   Efface et redessine le pendule
    %
    %   Fonction CALLBACK (appel�e automatiquement lorsque l'utilisateur interagit avec l'interface graphique)
    %   Re�oit  elementGraphique : l'�lement de l'IHM concern� (un bouton, un champ)
    %           evenementGraphique : l'interaction en question (un clic, un appui de touche)
    %   Retourne 0

    % R�cup�re les donn�es entr�es dans l'IHM
    fenetre = guidata(elementGraphique);
    m1 = str2double(get(fenetre.editM1, 'String'));
    m2 = str2double(get(fenetre.editM2, 'String'));
    L1 = str2double(get(fenetre.editL1, 'String'));
    L2 = str2double(get(fenetre.editL2, 'String'));
    theta1 = deg2rad(str2double(get(fenetre.editTheta1, 'String')));
    theta2 = deg2rad(str2double(get(fenetre.editTheta2, 'String')));
    champs = get(fenetre.selection, 'String');
    indexSelectionne = get(fenetre.selection, 'Value');
    
    global gJouer;
    gJouer = 0;
    set(fenetre.boutonPause, 'String', 'Play/Pause');
    
    % Calcule les nouvelles positions du pendule
    X = polaireVersCartesien(L1, theta1, L2, theta2);
    x1 = X(1);
    y1 = X(2);
    x2 = X(3);
    y2 = X(4);
    
    % Efface la zone de dessin et redessine le pendule
    axes(fenetre.dessin);
    cla reset;

    % Ces actions r�solvent les �quations de 2 pendule, donc on utilise les couleurs du 2e pendule
    %  d�s que l'action est s�lectionn�e
    if strcmp(champs{indexSelectionne},'R�solution des �quations non-lin�aires x2') || strcmp(champs{indexSelectionne},'R�solution des �quations lin�aires + non-lin�aires')
        couleur1 = 'Yellow';
        couleur2 = 'Green';
    else
        couleur1 = 'Red';
        couleur2 = 'Blue';
    end
    
    hold on;
    plot(x1,y1,'k.','MarkerSize', round(20*m1), 'Color', couleur1);
    plot(x2,y2,'k.','MarkerSize', round(20*m2), 'Color', couleur2);
    plot([0,x1],[0,y1],'LineWidth', 1, 'Color', couleur1);
    plot([x1,x2],[y1,y2],'LineWidth', 1, 'Color', couleur2);
    hold off;
    
    % Centre le pendule et laisse une petite marge
    Lmax = L1+L2+1;
    axis([ -Lmax Lmax -Lmax Lmax]);
end

function lancer(elementGraphique, ~)
    %% LANCER : Lance les calculs puis l'animation choisie par l'utilisateur
    %
    %   Fonction CALLBACK (appel�e automatiquement lorsque l'utilisateur interagit avec l'interface graphique)
    %   Re�oit  elementGraphique : l'�lement de l'IHM concern� (un bouton, un champ)
    %           evenementGraphique : l'interaction en question (un clic, un appui de touche)
    %   Retourne 0
    
    % R�cup�re les donn�es entr�es dans l'IHM
    fenetre = guidata(elementGraphique);
    m1 = str2double(get(fenetre.editM1, 'String'));
    m2 = str2double(get(fenetre.editM2, 'String'));
    L1 = str2double(get(fenetre.editL1, 'String'));
    L2 = str2double(get(fenetre.editL2, 'String'));
    pas = str2double(get(fenetre.editPas, 'String'));
    g = str2double(get(fenetre.editG, 'String'));
    dt = str2double(get(fenetre.editDt, 'String'));
    nbPasTemps = str2double(get(fenetre.editNb_iter_t, 'String'));
    theta1 = deg2rad(str2double(get(fenetre.editTheta1, 'String')));
    theta2 = deg2rad(str2double(get(fenetre.editTheta2, 'String')));
    dtheta1 = deg2rad(str2double(get(fenetre.editDTheta1, 'String')));
    dtheta2 = deg2rad(str2double(get(fenetre.editDTheta2, 'String')));
    champs = get(fenetre.selection, 'String');
    indexSelectionne = get(fenetre.selection, 'Value');

    global gJouer gTrace;
    gJouer = 0;
    gTrace = 0;
    
    % Conditions initiales
    Y0 = [ theta1; dtheta1; theta2; dtheta2];
    X0 = [theta1; theta2];
    Xp0=[ dtheta1; dtheta2];
    axes(fenetre.dessin);

    % Switch principal : selon l'action s�lectionn�e, on agit en cons�quence
    % Pour chaque action on lance la r�solution avec des valeurs dans la base polaire,
    % on convertit ces valeurs dans la base cart�sienne, puis on appelle affichage()
    messageAttente = waitbar(0, 'R�solution ...');
    switch champs{indexSelectionne}
        case 'R�solution des �quations lin�aires (ODE45)'
            [~, Y] = ode45(@(t,Y) fonctionPendule(m1, m2, L1, L2, g, Y), dt*(0:nbPasTemps), Y0, odeset('RelTol',1e-5));
            Y = Y';
            Pos = polaireVersCartesien(L1, Y(1, :), L2, Y(3, :));
            
            delete(messageAttente);
            affichage(elementGraphique, Pos);
            
        case 'R�solution des �quations lin�aires (Verlet)'
            Y = Verlet(dt, nbPasTemps, Y0, m1, m2, L1, L2, g);
            Pos = polaireVersCartesien(L1, Y(1, :), L2, Y(3, :));
            
            delete(messageAttente);
            affichage(elementGraphique, Pos);
            
        case 'Solution analytique des �quations lin�aires'
            X = Analytique(m1, m2, L1, L2, g, Y0, dt, nbPasTemps);
            Pos = polaireVersCartesien(L1, X(1, :), L2, X(2, :));
            
            delete(messageAttente);
            affichage(elementGraphique, Pos);

        case 'R�solution des �quations non-lin�aires (ODE45)'
            [~, Y] = ode45(@(t,Y) fonctionPenduleNonLineaire(m1, m2, L1, L2, g, Y),  dt*(0:nbPasTemps), Y0, odeset('RelTol',1e-10));
            Y = Y';
            Pos = polaireVersCartesien(L1, Y(1, :), L2, Y(3, :));
            
            delete(messageAttente);
            affichage(elementGraphique, Pos);

        case 'R�solution des �quations non-lin�aires (NNR)'
            [X, ~] = NewmarkNewtonRaphson(m1, m2, L1, L2, g, X0, Xp0, dt, nbPasTemps, 1);
            Pos = polaireVersCartesien(L1, X(1, :), L2, X(2, :));
            
            delete(messageAttente);
            affichage(elementGraphique, Pos);

        case 'R�solution des �quations non-lin�aires x2'
            X0 = [theta1; theta2];
            X0_2 = [theta1 + deg2rad(0.1); theta2];
            Xp0=[ dtheta1; dtheta2];
            [X, ~] = NewmarkNewtonRaphson(m1, m2, L1, L2, g, X0, Xp0, dt, nbPasTemps, 1);
            [X_2, ~] = NewmarkNewtonRaphson(m1, m2, L1, L2, g, X0_2, Xp0, dt, nbPasTemps, 1);
            
            Pos = polaireVersCartesien(L1, X(1, :), L2, X(2, :));
            Pos_2 = polaireVersCartesien(L1, X_2(1, :), L2, X_2(2, :));
            
            delete(messageAttente);
            affichage(elementGraphique, Pos, Pos_2);

        case 'R�solution des �quations lin�aires + non-lin�aires'          
            [X, ~] = NewmarkNewtonRaphson(m1, m2, L1, L2, g, X0, Xp0, dt, nbPasTemps, 1);
            Pos = polaireVersCartesien(L1, X(1, :), L2, X(2, :));

            X_2 = Analytique(m1, m2, L1, L2, g, Y0, dt, nbPasTemps);
            Pos_2 = polaireVersCartesien(L1, X_2(1,:), L2, X_2(2,:));
            
            delete(messageAttente);
            affichage(elementGraphique, Pos, Pos_2);
            M = max(abs(X), [], 2);
            err = abs(X - X_2)./M;
            err = mean(err, 2)*100;
            assignin('base', 'erreurLinearite', err);

            
        case 'Energie du pendule au cours du temps'
            % On calcule les deux solutions avec la m�me pr�cision pour pouvoir comparer :
            % Newmark Newton Raphson est toujours calcul� avec une pr�cision de 1e-11
            % Partout ailleurs on utilise ODE45 avec une pr�cision relative de 1e-10
            % mais on lui sp�cifie ici une pr�cision absolue de 1e-11
            [X, Xp] = NewmarkNewtonRaphson(m1, m2, L1, L2, g, X0, Xp0, dt, nbPasTemps, 1);
            E = Energie(m1, m2, L1, L2, g, X, Xp, dt, nbPasTemps);
            [~, Y] = ode45(@(t,Y) fonctionPenduleNonLineaire(m1, m2, L1, L2, g, Y),  dt*(0:nbPasTemps), Y0, odeset('AbsTol',1e-11));
            Y = Y';
            X_2 = [Y(1, :); Y(3, :)];
            Xp_2 = [Y(2, :); Y(4, :)];
            E_2 = Energie(m1, m2, L1, L2, g, X_2, Xp_2, dt, nbPasTemps);
            delete(messageAttente);

            figure();
            t = (0:nbPasTemps)*dt;
            plot(t, abs(E), 'b', t, abs(E_2), 'r');

            zoom yon;
            zoom(1/10);
            title('Energie m�canique du syst�me', 'FontSize', 12);
            legend('Equations non-lin�aires avec Newmark + Newton-Raphson', 'Equations non-lin�aires avec ODE45')
            xlabel('Temps (en sec)');
            ylabel('Energie (en J)');
            
        case ['Portaits de phase, section de Poincar� en ', char(952) '2']
            [X, Xp] = NewmarkNewtonRaphson(m1, m2, L1, L2, g, X0, Xp0, dt, nbPasTemps, 1);
            Pos = polaireVersCartesien(L1, X(1, :), L2, X(2, :));
            delete(messageAttente);

            % Portaits de phase
            f1 = figure();
            movegui(f1, 'northwest');
            hold on;
            X = mod(X+pi, 2*pi)-pi;
            plot(X(1,:), Xp(1,:), '.b');
            plot(X(2,:), Xp(2,:), '.r');
            hold off;
            title(['Portaits de phase en ', char(952), '1 et ', char(952), '2']);
            legend([char(952), '1'], [char(952), '2']);
            xlabel('Angle(en rad)');
            ylabel('Vitesse angulaire (en rad/s)');
            
            % Section de Poincar�
            section = sectionPoincare(X, Xp, nbPasTemps);
            f2 = figure();
            movegui(f2, 'northeast');
            plot(section(1, :), section(2, :), '*');
            axis([ -pi pi -8 8]);
            title(['Section de Poincar� en ', char(952), '2, � l''intersection du pendule 1 avec la droite x = 0']);
            xlabel(['Angle ',char(952) '2']);
            ylabel(['Vitesse d',char(952) '2/dt']);
            
            % Affichage avec trace
            gTrace = 1;
            affichage(elementGraphique, Pos);

        case '(Graphique) Diagramme de bifurcation'
            graph = diagrammeBifurcation(m1, m2, L1, L2, g, dt, nbPasTemps, pas);
            delete(messageAttente);

            figure();
            hold on;
            for i=2:1:size(graph,2)
                plot(graph(1,:),graph(i,:),'.b');
            end
            hold off;
            axis([0 180 -10 10]);
            title(['Diagramme de bifurcation en ',char(952) '2']);

        case '(Graphique) Temps de retournement'
            nbPasTemps = round(40/dt);
            graph = tempsDeRetournement(m1, m2, L1, L2, g, dt, nbPasTemps, pas);
            assignin('base', ['GTR',num2str(pas),'_',num2str(m1),num2str(m2),num2str(L1),num2str(L2)], graph);
            delete(messageAttente);

            figure();
            axe = -180:pas:180;
            pcolor(axe, axe, graph);
            caxis([0 5]);
            colorbar;
            title('Temps de retournement pour un l�cher de pendule double (� vitesse initiale nulle), en fonction de l''angle initial');
            xlabel([char(952) '1 (en �)']);
            ylabel([char(952) '2 (en �)']);
            xticks(-180:30:180);
            yticks(-180:30:180);
            
        case '(Graphique) Limite de la p�riodicit�'
            graph = limiteDeLaPeriodicite(m1, m2, L1, L2, g, dt, nbPasTemps, pas);
            assignin('base', ['GLP',num2str(pas)], graph);
            delete(messageAttente);

            figure();
            axe = -180:pas:180;
            pcolor(axe, axe, graph);
            caxis([0 300]);
            colorbar;
            title('Mesure du chaos pour un l�cher de pendule double (� vitesse initiale nulle)');
            xlabel([char(952) '1 (en �)']);
            ylabel([char(952) '2 (en �)']);
            xticks(-180:30:180);
            yticks(-180:30:180);
            
        case '(Graphique) Limite de la lin�arit�'
            nbPasTemps = round(200/dt);
            graph = limiteDeLaLinearite(m1, m2, L1, L2, g, dt,nbPasTemps, pas);
            assignin('base', ['GLL',num2str(pas)], graph);
            delete(messageAttente);
            
            figure();
            axe = -180:pas:180;
            plot(axe, graph);
            title(['Domaine de validit� de l''hypoth�se des angles faibles pour un l�cher de pendule double (� vitesse initiale nulle) avec ', char(952),'10 = ',char(952),'20']);
            xlabel([char(952) ' (en �)']);
            ylabel('Erreur');
            xticks(-180:30:180);
    end
end

function affichage(pointeurIHM, Pos, Pos_2)
    %% AFFICHAGE : Lance l'animation du pendule
    %   Lance l'animation pour un pendule, �ventuellement un 2e simultan�ment s'il est sp�cifi�
    %   Autorise � faire des pauses dans l'animation, � l'acc�lerer ou la ralentir par des variables globales
    %
    %   affichage() re�oit un pointeur vers l'interface graphique mais ce n'est pas une fonction CALLBACK.
    %
    %   Re�oit  pointeurIHM : une r�f�rence quelconque � un �l�ment de l'interface, pour r�cup�rer les donn�es
    %           Pos : les positions cart�siennes du pendule � animer, de la forme (x1, y1, x2, y2)
    %           Pos_2 : �ventuellement, les positions cart�siennes du 2e pendule � animer, de la forme (x1, y1, x2, y2)
    %
    %   Retourne 0

    % R�cup�re les donn�es entr�es � gr�ce au pointeur sur l'interface graphique
    fenetre = guidata(pointeurIHM);
    m1 = str2double(get(fenetre.editM1, 'String'));
    m2 = str2double(get(fenetre.editM2, 'String'));
    L1 = str2double(get(fenetre.editL1, 'String'));
    L2 = str2double(get(fenetre.editL2, 'String'));
    dt = str2double(get(fenetre.editDt, 'String'));
    nbPasTemps = str2double(get(fenetre.editNb_iter_t, 'String'));
    champs = get(fenetre.selection, 'String');
    indexSelectionne = get(fenetre.selection, 'Value');
    
    global gJouer gPause gPasDeTemps gTrace;
    gJouer = 1;
    gPause = 0;

    % Efface la zone de dessin et dessine la position initiale du pendule
    Lmax = L1+L2+1;
    axes(fenetre.dessin);
    cla reset;
    
    x1 = Pos(1,:);
    y1 = Pos(2,:);
    x2 = Pos(3,:);
    y2 = Pos(4,:);
    
    hold on;
    pendule1 = plot(x1(1),y1(1),'k.','MarkerSize', round(20*m1), 'Color', 'red');
    pendule2 = plot(x2(1),y2(1),'k.','MarkerSize', round(20*m2), 'Color', 'blue');
    tige1 = plot([0,x1(1)],[0,y1(1)],'LineWidth',1, 'Color', 'red');
    tige2 = plot([x1(1),x2(1)],[y1(1),y2(1)],'LineWidth',1,  'Color', 'blue');
    if gTrace == 1
        nbPointsTraj = 1000;
        traj = plot(x1(1),y1(1));
    end
    
    % Dessine eventuellement les positions initiales du 2e pendule
    if (exist('Pos_2', 'var'))
        x1_2 = Pos_2(1,:);
        y1_2 = Pos_2(2,:);
        x2_2 = Pos_2(3,:);
        y2_2 = Pos_2(4,:);

        pendule1_2 = plot(x1_2(1),y1_2(1),'k.','MarkerSize', round(20*m1), 'Color', 'yellow');
        pendule2_2 = plot(x2_2(1),y2_2(1),'k.','MarkerSize', round(20*m2), 'Color', 'green');
        tige1_2 = plot([0,x1_2(1)],[0,y1_2(1)],'LineWidth',1, 'Color', 'yellow');
        tige2_2 = plot([x1_2(1),x2_2(1)],[y1_2(1),y2_2(1)],'LineWidth',1, 'Color', 'green');
        
        % L�gende pour pr�ciser quel pendule est issu de quelles �quations
        if strcmp(champs{indexSelectionne}, 'R�solution des �quations lin�aires + non-lin�aires')
            legend([pendule1, pendule1_2], 'Solutions des �quations non-lin�aires',...
                'Solution des �quations lin�aires', 'AutoUpdate', 'Off');
        end
    end
    hold off;
    axis ([ -Lmax Lmax -Lmax Lmax]);

    % Animation : met � jour les cooordonn�es du pendule et fait des pauses
    i = 1;
    pourcent = 0;

    % Animation pour 2 pendules simultan�s
    if (exist('Pos_2', 'var'))
        while i <= nbPasTemps+1 && gJouer == 1
            if gPause == 0
                % double-pendule n�1
                set(pendule1,'XData', x1(i), 'YData', y1(i));
                set(pendule2,'XData', x2(i), 'YData', y2(i));
                set(tige1,'XData', [0,x1(i)], 'YData', [0,y1(i)]);
                set(tige2,'XData', [x1(i), x2(i)], 'YData', [y1(i), y2(i)]);
                % double-pendule n�2
                set(pendule1_2,'XData', x1_2(i), 'YData', y1_2(i));
                set(pendule2_2,'XData', x2_2(i), 'YData', y2_2(i));
                set(tige1_2,'XData', [0,x1_2(i)], 'YData', [0,y1_2(i)]);
                set(tige2_2,'XData', [x1_2(i), x2_2(i)], 'YData', [y1_2(i), y2_2(i)]);
                % Met � jour le pourcentage de l'animation
                if round(i*100/nbPasTemps) > pourcent
                    pourcent=round(i*100/nbPasTemps);
                    set(fenetre.boutonPause, 'String', [num2str(pourcent), '%']);
                end
                i = i+1;
            end
            pause(dt/gPasDeTemps);
        end
        
    % Animation pour un seul pendule    
    else
        % Avec la trace
        if gTrace == 1
            while i <= nbPasTemps+1 && gJouer == 1
                if gPause == 0
                    set(pendule1,'XData', x1(i), 'YData', y1(i));
                    set(pendule2,'XData', x2(i), 'YData', y2(i));
                    set(tige1,'XData', [0,x1(i)], 'YData', [0,y1(i)]);
                    set(tige2,'XData', [x1(i), x2(i)], 'YData', [y1(i), y2(i)]);

                    % Trajectoire
                    if i <= nbPointsTraj
                        set(traj, 'XData', x2(1:i), 'YData', y2(1:i));
                    else
                        set(traj, 'XData', x2(i-nbPointsTraj:i), 'YData', y2(i-nbPointsTraj:i));
                    end
                    
                    % Met � jour le pourcentage de l'animation
                    if round(i*100/nbPasTemps) > pourcent
                        pourcent=round(i*100/nbPasTemps);
                        set(fenetre.boutonPause, 'String', [num2str(pourcent), '%']);
                    end
                    i = i+1;
                end
                pause(dt/gPasDeTemps);
            end
        % Sans la trace
        else
            while i <= nbPasTemps+1 && gJouer == 1
                if gPause == 0
                    set(pendule1,'XData', x1(i), 'YData', y1(i));
                    set(pendule2,'XData', x2(i), 'YData', y2(i));
                    set(tige1,'XData', [0,x1(i)], 'YData', [0,y1(i)]);
                    set(tige2,'XData', [x1(i), x2(i)], 'YData', [y1(i), y2(i)]);
                    % Met � jour le pourcentage de l'animation
                    if round(i*100/nbPasTemps) > pourcent
                        pourcent=round(i*100/nbPasTemps);
                        set(fenetre.boutonPause, 'String', [num2str(pourcent), '%']);
                    end
                    i = i+1;
                end
                pause(dt/gPasDeTemps);
            end
        end
    end
end