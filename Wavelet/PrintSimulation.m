function img = PrintSimulation(img, i) 

    %Aumento na imagem para evitar perda de informação da textura
    img = imresize(img,i);
    
    %Aplicação do errordiffusion(Simulação de Impressão)
    img = errordifusion2(img);
    
    %Aplicação do filtro(Simulação de Escaneamento)
    h = ones(3,3)/3^2;
    img = imfilter(img,h);
    
    %Redução da imagem para o tamanho original
    img = imresize(img,1/i);
end