function showFourier(toShow)
% SHOW FOURIER - show images/series and their fourier transforms
%   toShow - a cell array of images or timeseires

    if ndims(toShow{1}) == 1
        figure;
        for ii = 1:length(toShow)
            subplot(3, length(toShow), ii);
            plot(toShow{ii}, []);
            subplot(3, length(toShow), length(toShow) + ii);
            ft = log(abs(fftshift(fft(toShow{ii}))));
            plot(ft, []);
            subplot(3, length(toShow), length(toShow)*2 + ii);
            ft = abs(fftshift(fft(toShow{ii})));
            plot(ft, []);
        end
    elseif ndims(toShow{1}) == 2
        figure;
        for ii = 1:length(toShow)
            subplot(3, length(toShow), ii);
            imshow(toShow{ii}, []);
            subplot(3, length(toShow), length(toShow) + ii);
            ft = log(abs(fftshift2(fft2(toShow{ii}))));
            imshow(ft, []);
            subplot(3, length(toShow), length(toShow)*2 + ii);
            ft = abs(fftshift2(fft2(toShow{ii})));
            imshow(ft, []);
        end
    else
        assert(false, 'Must be 1 or 2 dimensional')
    end
end