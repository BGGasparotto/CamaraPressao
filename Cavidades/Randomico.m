close all
clear all
clc
%% Criação das coordenadas randômicas
N = 600;
L = 80 ; %largura
P = 100; %profundidade
A = 130; %altura
a = rand(N,3);
b(:,1) = L * a(:,1);
b(:,2) = P * a(:,2);
b(:,3) = A * a(:,3);
%% Criação dos diâmetros randômicos
d = rand(N,1);
c = 5 + 5 .* d;
m = mean (c);
r = c/2;
%% Criação da matriz macro
e(:,1) = b(:,1);
e(:,2) = b(:,2);
e(:,3) = b(:,3);
e(:,4) = r;
%% Condição de parede
f(:,1) = b(:,1)+e(:,4);
f(:,2) = b(:,2)+e(:,4);
f(:,3) = b(:,3)+e(:,4);
f(:,4) = e(:,4);
f(f(:,1)<6 |f(:,1)>74 | f(:,2)<6 ...
    | f(:,2)>94 | f(:,3)<6 | f(:,3)> 124, :) = [];
f2(:,1) = f(:,1)-2*f(:,4);
f2(:,2) = f(:,2)-2*f(:,4);
f2(:,3) = f(:,3)-2*f(:,4);
f2(:,4) = f(:,4);
f2(f2(:,1)<6 |f2(:,1)>74 | f2(:,2)<6 ...
    | f2(:,2)>94 | f2(:,3)<6 | f2(:,3)> 124, :) = [];
%% Condição de furo
g(:,1)=f2(:,1)+2*f2(:,4);
g(:,2)=f2(:,2)+2*f2(:,4);
g(:,3)=f2(:,3)+2*f2(:,4);
g(:,4)=f2(:,4);
% g(g(:,1)>35.3 & g(:,1)<44.7 & g(:,3)<92,:)=[];
% g(g(:,2)>45.3 & g(:,2)<54.7 & g(:,3)<92,:)=[];
g2(:,1) = g(:,1)-2*g(:,4);
g2(:,2) = g(:,2)-2*g(:,4);
g2(:,3) = g(:,3)-2*g(:,4);
g2(:,4) = g(:,4);
% g2(g2(:,1)>35.3 & g2(:,1)<44.7 & g2(:,3)<92,:)=[];
% g2(g2(:,2)>45.3 & g2(:,2)<54.7 & g2(:,3)<92,:)=[];
%% Coordenadas restantes
h(:,1) = g2(:,1) + g2(:,4);
h(:,2) = g2(:,2) + g2(:,4);
h(:,3) = g2(:,3) + g2(:,4);
h(:,4) = g2(:,4);
%% Condicao de sobreposicao e eliminacao
h_final = h;   % mantém h original
[~,idx] = unique(h_final(:,1:3),'rows','stable');
h_final2 = h_final(idx,:); %elimina duplicatas
NS = size(h_final2,1);
    %% Cálculo das distâncias
DS = NaN(NS,NS);
for i = 1:NS-1
    ds = sqrt((h_final2(i,1)-h_final2(i+1:NS,1)).^2 + ...
              (h_final2(i,2)-h_final2(i+1:NS,2)).^2 + ...
              (h_final2(i,3)-h_final2(i+1:NS,3)).^2);
    DS(i,i+1:NS) = ds;
    DS(i+1:NS,i) = ds;
end
  %% Soma dos raios
DSR = NaN(NS,NS);
for i = 1:NS-1
    dsr = h_final2(i,4) + h_final2(i+1:NS,4) + 0.2;
    DSR(i,i+1:NS) = dsr;
    DSR(i+1:NS,i) = dsr;
end
%% Razão entre distância e soma dos raios
DR = DS./DSR;
soma_DR = sum(DR,2,'omitnan');
DR = [DR soma_DR];
% Índices originais das bolinhas
id_bolas = (1:NS)';
[~,ordem] = sort(DR(:,end),'descend');
DR2 = DR(ordem,:);
% Reordena h na mesma ordem
h_final3 = h_final2(ordem,:);
%% Verificação de sobreposição em h_final3
NS3 = size(h_final3,1);
pares_sobreposicao = [];
for i = 1:NS3-1
    for j = i+1:NS3
        % distância entre centros
        distancia = sqrt((h_final3(i,1)-h_final3(j,1))^2 + ...
                         (h_final3(i,2)-h_final3(j,2))^2 + ...
                         (h_final3(i,3)-h_final3(j,3))^2);
        % distância permitida (raios + folga)
        distancia_limite = h_final3(i,4) + h_final3(j,4) + 0.2;
        % interferência
        interferencia = distancia_limite - distancia;
        % se for positivo, existe sobreposição
        if interferencia > 0
            pares_sobreposicao = [pares_sobreposicao;
                    i, j, distancia, distancia_limite, interferencia];
        end
    end
end

%% Cálculo do volume das esferas
volume = (4/3)*pi*(h_final3(:,4).^3);
% adiciona o volume como 5ª coluna
h_final3(:,5) = volume;
% volume total
volume_total = sum(volume);
fprintf('Volume total das bolinhas = %.4f\n', volume_total);
h_final4(:,1) = h_final3(:,1);
h_final4(:,2) = h_final3(:,2);
h_final4(:,3) = h_final3(:,3);
h_final4(:,4) = 2*h_final3(:,4);
% writematrix(h_final4,'h_final4.csv');

scatter3(h_final4(:,1),h_final4(:,2),h_final4(:,3))