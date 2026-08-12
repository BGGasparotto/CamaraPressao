close all
clear all
clc
%% Controle da aleatoriedade
rng('shuffle')  % gera uma nova amostra aleatória
estado_rng = rng; % salva o estado usado
%% Criação das coordenadas randômicas
N = 1300;
L = 70 ; %largura
P = 70; %profundidade
A = 90; %altura
Volume_cubo = L*P*A;
T = 2; %parede
a = rand(N,3);
b(:,1) = L * a(:,1);
b(:,2) = P * a(:,2);
b(:,3) = A * a(:,3);
numero_inicial = size(b,1);
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
f(f(:,1)<T |f(:,1)>L-T | f(:,2)<T ...
    | f(:,2)>P-T | f(:,3)<T | f(:,3)> A-T, :) = [];
f2(:,1) = f(:,1)-2*f(:,4);
f2(:,2) = f(:,2)-2*f(:,4);
f2(:,3) = f(:,3)-2*f(:,4);
f2(:,4) = f(:,4);
f2(f2(:,1)<T |f2(:,1)>L-T | f2(:,2)<T ...
    | f2(:,2)>P-T | f2(:,3)<T | f2(:,3)> A-T, :) = [];
numero_apos_parede = size(f2,1);
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
numero_apos_furo = size(g2,1);
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
writematrix(h_final4,'h_final1.csv');
%% ===============================
% Estatísticas da amostra
% ===============================
diametros = 2*h_final3(:,4);
diametro_medio = mean(diametros);
desvio_padrao = std(diametros);
numero_cavidades = size(h_final3,1);
volume_cavidades = sum(h_final3(:,5));
%% Volume de sobreposição
volume_sobreposto = 0;
bolas_sobrepostas = unique([pares_sobreposicao(:,1); 
                            pares_sobreposicao(:,2)]);
numero_bolas_sobrepostas = length(bolas_sobrepostas);
% cálculo aproximado do volume sobreposto
for i = 1:size(pares_sobreposicao,1)
    r1 = h_final3(pares_sobreposicao(i,1),4);
    r2 = h_final3(pares_sobreposicao(i,2),4);
    d = pares_sobreposicao(i,3);
    % fórmula da interseção de duas esferas
    if d < abs(r1-r2)
        v = (4/3)*pi*min(r1,r2)^3;
    else
        h1 = (r1+r2-d)*(r1-r2+d)/(2*d);
        h2 = (r1+r2-d)*(r2-r1+d)/(2*d);
        v = pi*h1^2*(r1-h1/3) + ...
            pi*h2^2*(r2-h2/3);
    end
    volume_sobreposto = volume_sobreposto + v;
end
Volume_Poroso = Volume_cubo - volume_cavidades + volume_sobreposto;
Volume_Bolas = Volume_cubo - Volume_Poroso;
Porosidade = (Volume_Bolas/Volume_cubo)*100;
%% ===============================
% Criar arquivo TXT
% ===============================
arquivo_txt = fopen('Dados_Amostra.txt','w');
fprintf(arquivo_txt,'Dados da amostra aleatoria\n');
fprintf(arquivo_txt,'==========================\n\n');
fprintf(arquivo_txt,'Numero de cavidades: %d\n',numero_cavidades);
fprintf(arquivo_txt,'Numero inicial de coordenadas randomicas: %d\n',numero_inicial);
fprintf(arquivo_txt,'Numero apos condicao de parede: %d\n',numero_apos_parede);
fprintf(arquivo_txt,'Numero apos condicao de furo: %d\n',numero_apos_furo);
fprintf(arquivo_txt,'Numero apos coincidencia: %d\n',NS);
fprintf(arquivo_txt,'Diametro medio: %.6f mm\n',diametro_medio);
fprintf(arquivo_txt,'Desvio padrao dos diametros: %.6f mm\n',desvio_padrao);
fprintf(arquivo_txt,'Volume total das cavidades: %.6f mm3\n',volume_cavidades);
fprintf(arquivo_txt,'Volume total de sobreposicao: %.6f mm3\n',volume_sobreposto);
fprintf(arquivo_txt,'Volume cubo: %.6f mm3\n',Volume_cubo);
fprintf(arquivo_txt,'Porosidade: %.6f porcento\n',Porosidade);
fprintf(arquivo_txt,'Numero de bolinhas sobrepostas: %d\n',numero_bolas_sobrepostas);
fclose(arquivo_txt);
%% ===============================
% Salvar arquivo MAT
% ===============================
save('Amostra_Aleatoria.mat',...
    'h_final3',...
    'h_final4',...
    'pares_sobreposicao',...
    'diametros',...
    'diametro_medio',...
    'desvio_padrao',...
    'volume_cavidades',...
    'volume_sobreposto',...
    'numero_cavidades',...
    'numero_bolas_sobrepostas',...
    'numero_inicial',...
    'numero_apos_parede',...
    'numero_apos_furo',...
    'estado_rng',...
    'N','L','P','A')

scatter3(h_final4(:,1),h_final4(:,2),h_final4(:,3))