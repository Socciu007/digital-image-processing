I = imread("color\20250307.jpg");
subplot(1,2,1);
imshow(I)
title("RGB")
% RGB
R = I(:,:,1);
G = I(:,:,2);
B = I(:,:,3);

% Handle gray image
function gray_img = rgb2gray_custom(img, a, b, c)
    % Check a+b+c = 1
    if abs(a+b+c - 1) > 1e-6
        error('a+b+c phải = 1');
    end
    
    % Chuyển về double để tính toán chính xác
    %img = im2double(img);
    R = img(:,:,1);
    G = img(:,:,2);
    B = img(:,:,3);
    
    % Ảnh xám theo công thức tuyến tính
    gray_img = a*R + b*G + c*B;
end

% Gray image
Igray = rgb2gray_custom(I, 0.3, 0.3, 0.4);

% Convert to HSV
HSV = rgb2hsv(I);
H = HSV(:,:,1);
S = HSV(:,:,2);
V = HSV(:,:,3);

% Crop image
[rows, cols, ch] = size(I);
startCol = floor((cols - 2400)/2) + 1;
endCol   = startCol + 2400 - 1;

ICrop = I(:, startCol:endCol, :);
subplot(1,2,2);
imshow(ICrop)
title('Icrop 2400x2400')

% Show a little image after convert
J = [ICrop fliplr(ICrop) rot90(ICrop); flipud(ICrop) 255-ICrop 2*ICrop];
%figure; imshow(J)

% Bit-plane slicing
IGray = rgb2gray(ICrop);
%I = uint8(2*(2*(2*(2*(2*(2*(2*I7+I6)+I5)+I4)+I3)+I2)+I1)+I0)
bit_planes = false([size(Igray), 8]); % logical array h x w x 8
for k = 1:8
    bit_planes(:,:,k) = logical(bitget(Igray, k)); % k=1 -> LSB (Bit0)
end

figure
for k = 1:8
    subplot(2,4,k);
    imshow(bit_planes(:,:,k));
    title(sprintf('Bit %d', k-1));
end

% New image from bit4 -> bit 7
INew = zeros(size(Igray),'uint8');
for k = 5:8
    INew = INew + uint8(bit_planes(:,:,k)) * 2^(k-1);
end
figure; subplot(1,2,1); imshow(Igray);
subplot(1,2,2); imshow(INew);



