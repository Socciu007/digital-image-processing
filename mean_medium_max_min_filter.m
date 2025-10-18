function IOut = OutputI(I, k, type)
    if size(I, 3) == 1
        % Grayscale image
        IOut = MyFilterImage(I, k, type);
    elseif ndims(I) == 3
        % Color image (RGB)
        IOut = zeros(size(I), 'uint8');
        for c = 1:3
            IOut(:,:,c) = MyFilterImage(I(:,:,c), k, type);
        end
    else
        error('Unsupported image format.')
    end
end

%% Mean filter, median filter, max filter and min filter
% I: Gray Image (uint8)
% k: size of windows(masks) (3x3, 5x5, ...)
% type: 'mean', 'median', 'max', 'min'
function IOut = MyFilterImage(I, k, type)
    I = double(I); % Convert to double
    [m, n] = size(I);
    pad = floor(k/2); % pixel padding

    % Add padding (0 at border)
    IPad = padarray(I, [pad pad], 0, 'both');
    % Initial result image
    IOut = zeros(m, n);

    % Loop each pixel
    for i = 1:m
        for j = 1:n
            % Get mask kxk
            mask = IPad(i:i+k-1, j:j+k-1);
            w = mask(:);

            switch lower(type)
                case 'mean'
                    IOut(i, j) = mean(w);
                case 'median'
                    IOut(i, j) = median(w);
                case 'max'
                    IOut(i, j) = max(w);
                case 'min'
                    IOut(i, j) = min(w);
                otherwise
                    error('Please enter filter type.')
            end
        end
    end
    IOut = uint8(IOut); % Convert to uint8 image
end

%% Read image
I = imread('color\t18.jpg');
% I = im2gray(I);

% Crop image
% [rows, cols, ch] = size(I);
% startCol = floor((cols - 2400)/2) + 1;
% endCol   = startCol + 2400 - 1;
% I = I(:, startCol:endCol, :);

%% Create various types of noise images (to test)
INoisy = imnoise(I, 'salt & pepper', 0.05);
IGaussian = imnoise(I, 'gaussian', 0, 0.02);
ISalf = I;
ISalf(rand(size(I)) < 0.05) = 255;
IPepper = I;
IPepper(rand(size(I)) < 0.05) = 0;

%% Output Filter
IMean   = OutputI(IGaussian, 5, 'mean');
IMean3   = OutputI(IGaussian, 3, 'mean');
IMedian = OutputI(INoisy, 5, 'median');
IMedian3 = OutputI(INoisy, 3, 'median');
IMax    = OutputI(IPepper, 5, 'max');
IMin    = OutputI(ISalf, 5, 'min');

%% Show Image
figure;
subplot(1,4,1), imshow(I), title('Image Original');
subplot(1,4,2), imshow(IGaussian), title('Gaussian Noise');
subplot(1,4,3), imshow(IMean3), title('Mean Filter k=3');
subplot(1,4,4), imshow(IMean), title('Mean Filter k=5');
figure;
subplot(1,4,1), imshow(I), title('Image Original');
subplot(1,4,2), imshow(INoisy), title('Salf & Pepper Noise');
subplot(1,4,3), imshow(IMedian3), title('Median Filter k=3');
subplot(1,4,4), imshow(IMedian), title('Median Filter k=5');
figure;
subplot(1,2,1), imshow(IPepper), title('Pepper Noise');
subplot(1,2,2), imshow(IMax), title('Max Filter k=5');
figure;
subplot(1,2,1), imshow(ISalf), title('Salf Noise');
subplot(1,2,2), imshow(IMin), title('Min Filter k=5');



