clc
clear all

myFolder = 'IN';
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
    Image = ImageArray{k};;
    Image = cast(Image,'double');
    %Extração dos 3 canais(YCbCr)
    Y = 0.299*Image(:,:,1) + 0.587*Image(:,:,2) + 0.114*Image(:,:,3);
    Cb = 0.564*(Image(:,:,3) - Y);
    Cr = 0.713*(Image(:,:,1) - Y);

    %Dimunindo Cb e Cr pela metade
    Cb = imresize(Cb,0.5);
    Cr = imresize(Cr,0.5);

    %Criando os canais Cb e Cr com apenas com os coeficientes positivos
    %(Cbplus, Crplus) e com os negativos (Cbminus, Crminus)

    Cbplus = Cb;
    Cbminus = Cb;
    Crplus = Cr;
    Crminus = Cr;

    [M,N] = size(Cb);

    for i = 1:M
        for j = 1:N
            if Cb(i,j) < 0
                Cbplus(i,j) = 0;
            else
                Cbminus(i,j) = 0;
            end
        end
    end

    for i = 1:M
        for j = 1:N
            if Cr(i,j) < 0
                Crplus(i,j) = 0;
            else
                Crminus(i,j) = 0;
            end
        end
    end


    %Transformada Wavelet
    [c,s] = wavedec2(Y,2,'db1');

    %Extração dos coeficientes da Wavelet
    %Sl = Aproximação
    %Sh2,Sv2,Sd2 = Detalhes gerados pela primeira passada da wavelet
    %Sh1,Sv1,Sd1 = Detalhes gerados pela segunda passada da wavelet
    [Sh2,Sv2,Sd2] = detcoef2('all',c,s,1); 
    [Sh1,Sv1,Sd1] = detcoef2('all',c,s,2);
    Sl = appcoef2(c,s,'db1',2); 
    
    %Alterando os coeficientes para que eles se tornem vetores
    [M,N] = size(Sh2);
    Cbplus = reshape(Cbplus,[1,M*N]);
    Crplus = reshape(Crplus,[1,M*N]);
    Crminus = reshape(Crminus,[1,M*N]);

    %Reduzindo a Cbminus pela metade
    [M,N] = size(Sh1);
    Cbminus = imresize(Cbminus,0.5);

    %Alterando os coeficientes para que eles se tornem vetores
    Sh1 = reshape(Sh1,[1,M*N]);
    Sv1 = reshape(Sv1,[1,M*N]);
    Sl = reshape(Sl,[1,M*N]);
    Cbminus = reshape(Cbminus,[1,M*N]);

    %Substituindo as componentes da transformada pelos canais exigidos
    %Sd1 => Cbminus Sh2 => Crplus Sv2 => Cbplus Sd2 => Crminus 

    
    c = [Sl, Sh1, Sv1, Cbminus, Crplus, Cbplus, Crminus];


    %Transformada inversa
    NewY = waverec2(c,s,'db1');
    NewY = uint8(NewY);
    
    filename = sprintf('TEXTURE/%02d-imagetexture.png', k);
    imwrite(NewY, filename);
end



%imwrite(NewY, 'OUT/imagetexture.png');