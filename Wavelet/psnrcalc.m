function psnrcalc

    %Pega o nome das imagens da pasta IN
    myFolder = 'IN';
    filePattern = fullfile(myFolder, '*.png'); 
    theFiles = dir(filePattern);
    k = length(theFiles);

    %Pega o nome das imagens da pasta RECOVERED
    myFolderC = 'RECOVERED';
    filePattern = fullfile(myFolderC, '*.png'); 
    theFilesC = dir(filePattern);

    for j = 1:k

        baseFileName = theFilesC(j).name;
        filename2 = fullfile(myFolderC, baseFileName);

        baseFileName = theFiles(j).name;
        filename1 = fullfile(myFolder, baseFileName);


        Old = imread(filename1);
        New = imread(filename2);
        p(j) = psnr(Old, New);
    end
    p
end