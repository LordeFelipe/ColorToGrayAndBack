clc
clear all

tic
i = input('Deseja aplicar a simulação de impressão antes de recuperar a cor?\n[1]-sim\n[0]-não\n');

if(i == 1)
    i = input('Insira o valor do Resize da simulação de impressão\n');
end

myFolder = 'TEXTURE';
filePattern = fullfile(myFolder, '*.png'); 
theFiles = dir(filePattern);
nfiles = length(theFiles);

%Criando um array para armazenas todas as imagens
for k = 1 : nfiles 
  baseFileName = theFiles(k).name;
  fullFileName = fullfile(myFolder, baseFileName);
  ImageArray{k} = imread(fullFileName);
end

for k = 1:nfiles
    TexturedImage = ImageArray{k};
    %Simulação de impressão, o valor enviado é o tamanho do resize
    if i > 0
        TexturedImage = PrintSimulation(TexturedImage, i);
    end
    
    %Aplicando a transformada wavelet na imagem com textura
    [c,s] = wavedec2(TexturedImage,2,'db1');

    %Extraindo os coeficientes da wavelet
    %Sl = Aproximação
    %Sh2,Sv2,Sd2 = Detalhes gerados pela primeira passada da wavelet
    %Sh1,Sv1,Sd1 = Detalhes gerados pela segunda passada da wavelet
    [Sh2,Sv2,Sd2] = detcoef2('all',c,s,1);
    [Sh1,Sv1,Sd1] = detcoef2('all',c,s,2);
    Sl = appcoef2(c,s,'db1',2); 

    %Alterando o tamanho de Sd1 para que ela tenha o tamanho dos detalhes
    %gerados pela primeira passada da wavelet
    [M,N] = size(Sd2);
    Sd1 = imresize(Sd1,[M,N]);

    %Recuperando os valores de Cb e Cr que haviam sido armazenados dentro da
    %imagem texturizada
    Cb = abs(Sv2) - abs(Sd1);
    Cr = abs(Sh2) - abs(Sd2);

    %Zerando os coeficientes que antes armazenavam os canais Cb e Cr
    Sh2 = zeros(M,N);
    Sv2 = zeros(M,N);
    Sd2 = zeros(M,N);
    Sd1 = zeros(M,N);

    %Convertendo os coeficientes para vetores para fazer a transformada inversa
    Sh2 = reshape(Sh2,[1,M*N]);
    Sv2 = reshape(Sv2,[1,M*N]);
    Sd2 = reshape(Sd2,[1,M*N]);
    Sd1 = reshape(Sd1,[1,M*N]);

    %Convertendo os coeficientes para vetores para fazer a transformada inversa
    [M,N] = size(Sh1);
    Sh1 = reshape(Sh1,[1,M*N]);
    Sv1 = reshape(Sv1,[1,M*N]);
    Sl = reshape(Sl,[1,M*N]);

    %Transformada wavelet inversa
    c = [Sl, Sh1, Sv1, Sd1, Sh2, Sv2, Sd2];
    TexturedImage = waverec2(c,s,'db1');

    %Dobrando o tamanho dos canais Cb e Cr extraídos da imagem
    [M,N] = size(TexturedImage);
    Cb = imresize(Cb,[M,N]);
    Cr = imresize(Cr,[M,N]);
    Y = TexturedImage;
    
    %Conversão de volta para YCbCr
    ColoredImage = zeros(M,N,3);
    
    ColoredImage(:,:,1) = Y + 1.402*Cr;
    ColoredImage(:,:,2) = Y - 0.344*Cb - 0.714*Cr; 
    ColoredImage(:,:,3) = Y + 1.772*Cb;
    ColoredImage = uint8(ColoredImage);
    
    filename = sprintf('RECOVERED/%02d-RecoveredColor.png', k);
    imwrite(ColoredImage, filename);
end

i = input('RECUPERAÇÃO CONCLUÍDA\nDeseja calcular o psnr das imagens na ordem que elas são apresentadas na pasta TEXTURE?\n[1]-sim\n[0]-não\n');

if i == 1
    psnrcalc
end

i = input('Deseja gerar as imagens com saturação aumentada na pasta SATBOOST?\n[1]-sim\n[0]-não\n');

if i == 1
    satboost
end

toc