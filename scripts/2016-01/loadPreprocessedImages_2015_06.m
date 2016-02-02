function [imOTS, imSOC, pprcss] = loadPreprocessedImages_2015_06()
    pprcss.aOld = 0;
    pprcss.eOld = 1;
    pprcss.aNew = 0.75;
    pprcss.eNew = 8;
    pprcss.r = 1;
    pprcss.s = 0.5;

    inputDir = fullfile('data', 'preprocessing', '2015-09-13');
    inputFile = ['junstimuli_r', strrep(num2str(pprcss.r), '.', 'pt'),...
        '_s', strrep(num2str(pprcss.s), '.', 'pt'),...
        '_a', strrep(num2str(pprcss.aOld), '.', 'pt'),...
        '_e', strrep(num2str(pprcss.eOld), '.', 'pt'), '.mat'];
    load(fullfile(rootpath, inputDir, inputFile), 'preprocess');
    imStack = flatToStack(preprocess.contrast, 9);
    imPxv = stackToPxv(imStack);
    imSOC = permute(imPxv, [2 1 3]);

    inputDir = fullfile('data', 'preprocessing', '2015-09-13');
    inputFile = ['junstimuli_r', strrep(num2str(pprcss.r), '.', 'pt'),...
        '_s', strrep(num2str(pprcss.s), '.', 'pt'),...
        '_a', strrep(num2str(pprcss.aNew), '.', 'pt'),...
        '_e', strrep(num2str(pprcss.eNew), '.', 'pt'), '.mat'];
    load(fullfile(rootpath, inputDir, inputFile), 'preprocess');
    imStack = flatToStack(preprocess.contrast, 9);
    imPxv = stackToPxv(imStack);
    imOTS = permute(imPxv, [2 1 3]); 
end
