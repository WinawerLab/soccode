function test_cellToStack()
%TEST: CELL TO STACK - Test the cellToStack function
    test_outputDims()
    test_wrongFrames()
end

function test_outputDims()
    X = 800;
    Y = 800;
    C = 3;
    F = 6;
    
    for i = 1:C
        stimCell{i} = randn(X, Y, F);
    end
    
    stack = cellToStack(stimCell);
    
    assertEqual(size(stack), [X Y C F]);
    
end

function test_wrongFrames()
    stimCell{1} = randn(800, 800, 5); % Not the same number of frames
    stimCell{2} = randn(800, 800, 6);
    
    assertExceptionThrown(@() cellToStack(stimCell), 'MATLAB:catenate:dimensionMismatch');
end