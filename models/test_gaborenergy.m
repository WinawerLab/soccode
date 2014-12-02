function test_gaborenergy()
    test_size(1);
    test_size(5);
    test_rejectbands();
    % test_lookatme();
end

function test_size(numims)
   xy = 180; % can't be too small, or else spacing is totally wrong
   ims = ones(xy*xy, numims);

   numor = 8;
   numph = 2;
   result = gaborenergy(ims, numor, numph);
   
   newXY = 90; % TODO I actually don't know why it gets half the size
   expectSize = [newXY*newXY, numims, numor];
   
   assertEqual(size(result), expectSize);   
end

function test_rejectbands()
% Gaborenergy cannot run on more than one band - that is a type error.
% It only makes sense to do a band decomposition on a whole image.
    xy = 180;
    ims = 5;
    bands = 4;
    
    ims = ones(xy*xy, ims, bands);
    numor = 8; numph = 2;

    assertExceptionThrown(@() gaborenergy(ims, numor, numph), 'MATLAB:assertion:failed');
end

function test_lookatme() 
   im = getsampleimage();
   im = stackToFlat(im);

   numor = 8;
   numph = 2;
   result = gaborenergy(im, numor, numph);
   
   figure; imagesc(makeimagestack(flatToStack(result(:, :, 2))));
   % Does this look like a piece of an image? If so, reshaping worked?
end