close all
clear all
clc

%% =================================
% DIMENSÕES DO BLOCO (mm)
%% =================================

Lx = 100;
Ly = 80;
Lz = 130;

parede = 8;
folgaFuro = 0.20;      % mm
folgaEsferas = 0.30;   % mm

%% =================================
% FURO CENTRAL
%% =================================

Dfuro = 9;
Rfuro = Dfuro/2;

xfuro = 0;
yfuro = 0;

zfuro_inicio = 0;
zfuro_fim = 90;

%% =================================
% ESFERAS
%% =================================

N = 200;

Dmin = 5;
Dmax = 10;

% Matriz:
% X  Y  Z  D
esferas = zeros(N,4);

contador = 0;
tentativas = 0;
maxTentativas = 100000;

%% =================================
% GERAÇÃO DAS ESFERAS
%% =================================

while contador < N && tentativas < maxTentativas

    tentativas = tentativas + 1;

    %---------------------------------
    % Diâmetro aleatório
    %---------------------------------
    D = round((Dmin + rand()*(Dmax-Dmin)),1);
    R = D/2;

    %---------------------------------
    % Posição aleatória
    %---------------------------------

    X = (-Lx/2 + parede + R) + rand()*(Lx - 2*parede - 2*R);
    Y = (-Ly/2 + parede + R) + rand()*(Ly - 2*parede - 2*R);
    Z = (parede + R) + rand()*(Lz - 2*parede - 2*R);
    
    X = round(X,1);
    Y = round(Y,1);
    Z = round(Z,1);

    %---------------------------------
    % Verifica interferência com o furo
    %---------------------------------
    distanciaFuro = sqrt((X-xfuro)^2 + (Y-yfuro)^2);

    dentroFuro = ...
    distanciaFuro < (Rfuro + R + folgaFuro) && ...
    Z > (zfuro_inicio - R - folgaFuro) && ...
    Z < (zfuro_fim + R + folgaFuro);

    if dentroFuro
        continue
    end

    %---------------------------------
    % Verifica sobreposição
    %---------------------------------
    sobreposicao = false;

    for i = 1:contador

        dx = X - esferas(i,1);
        dy = Y - esferas(i,2);
        dz = Z - esferas(i,3);

        distancia = sqrt(dx^2 + dy^2 + dz^2);

        raioExistente = esferas(i,4)/2;

       if distancia < (R + raioExistente + folgaEsferas)
        sobreposicao = true;
        break
       end

    end 

    if sobreposicao
        continue
    end

    %---------------------------------
    % Aceita a esfera
    %---------------------------------
    contador = contador + 1;

    esferas(contador,:) = [X Y Z D];

    fprintf('Esfera %3d criada: X=%6.1f  Y=%6.1f  Z=%6.1f  D=%4.1f\n', ...
        contador,X,Y,Z,D);

end

%% =================================
% RESULTADO
%% =================================

if contador == N
    disp('================================');
    disp('200 esferas geradas com sucesso');
    disp('================================');
else
    disp('Não foi possível gerar todas');
end

%% =================================
% ORDENA DA MAIS AFASTADA PARA A MAIS PRÓXIMA
%% =================================

% Centro geométrico do bloco
xc = 0;
yc = 0;
zc = Lz/2;

distCentro = sqrt( ...
    (esferas(:,1)-xc).^2 + ...
    (esferas(:,2)-yc).^2 + ...
    (esferas(:,3)-zc).^2 );

[~,ordem] = sort(distCentro,'descend');

esferas = esferas(ordem,:);

%% =================================
% IMPRIME A TABELA ORDENADA
%% =================================

fprintf('\n');
disp('===============================================');
disp('ESFERAS ORDENADAS DA MAIS AFASTADA À MAIS PRÓXIMA');
disp('===============================================');

fprintf(' Nº       X       Y       Z       D\n');

for i = 1:N

    fprintf('%3d   %7.1f %7.1f %7.1f %6.1f\n', ...
        i,...
        esferas(i,1),...
        esferas(i,2),...
        esferas(i,3),...
        esferas(i,4));

end

%% =================================
% SALVA CSV
%% =================================

nomeArquivo = "esferas.csv";

writematrix(esferas,nomeArquivo);

disp("Arquivo esferas.csv criado")

%% =================================
% PLOT 3D DAS ESFERAS
%% =================================

figure
hold on
axis equal
grid on
box on

xlabel('X (mm)')
ylabel('Y (mm)')
zlabel('Z (mm)')
title('Distribuição das esferas')

% Gera uma esfera unitária
[xs,ys,zs] = sphere(30);

for i = 1:N

    R = esferas(i,4)/2;

    X = esferas(i,1);
    Y = esferas(i,2);
    Z = esferas(i,3);

    surf(R*xs + X,...
        R*ys + Y,...
        R*zs + Z,...
        'EdgeColor','none');

end

camlight
lighting gouraud
view(3)
% Limites do bloco
xlim([-Lx/2 Lx/2])
ylim([-Ly/2 Ly/2])
zlim([0 Lz])