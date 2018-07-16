function satboost
    myFolder = 'RECOVERED';
    filePattern = fullfile(myFolder, '*.png'); 
    theFiles = dir(filePattern);
    k = length(theFiles);

    for j = 1:k

        baseFileName = theFiles(j).name;
        filename = fullfile(myFolder, baseFileName);
        RGB = imread(filename);

        %A saturação de cada imagem é aumetada 1 vezes
        for i=1:2
            HSV = rgb2hsv(RGB);
            HSV(:, :, 2) = HSV(:, :, 2) * 1.2;
            HSV(HSV > 1) = 1;  % Limit values
            RGB = hsv2rgb(HSV);
        end
        filename = sprintf('SATBOOST/%02d-sat.png', j);
        imwrite(RGB, filename);
    end
end