clc; clear; close all; warning off;

%% Nhập ảnh
Iin = imgetfile;
Iin = imread(Iin);
[r, c, p] = size(Iin);
if p > 1
    Igray = rgb2gray(Iin);
else
    Igray = Iin;
end

I = double(Igray);
[m, n] = size(I);

%% --- ROBERTS Filter ---
% Mặt nạ Roberts
Gx_mask = [1 0; 0 -1];
Gy_mask = [0 1; -1 0];
% Khởi tạo kết quả
Gx = zeros(m, n);
Gy = zeros(m, n);
G = zeros(m, n);
% Tính đạo hàm riêng thủ công
for i = 1:m-1
    for j = 1:n-1
        % Trích vùng 2x2
        region = I(i:i+1, j:j+1);
        Gx(i,j) = sum(sum(region .* Gx_mask));
        Gy(i,j) = sum(sum(region .* Gy_mask));
        G(i,j) = sqrt(Gx(i,j)^2 + Gy(i,j)^2);
    end
end
% Results
figure;
subplot(1,3,1); imshow(uint8(I)); title('Ảnh gốc');
subplot(1,3,2); imshow(uint8(Gx)); title('Gradient theo X (Roberts)');
subplot(1,3,3); imshow(uint8(G)); title('Biên Roberts');

%% --- SOBEL Filter ---
% Mặt nạ Sobel
Gx_mask = [-1 0 1; -2 0 2; -1 0 1];
Gy_mask = [-1 -2 -1; 0 0 0; 1 2 1];

% Khởi tạo kết quả
Gx = zeros(m, n);
Gy = zeros(m, n);
G = zeros(m, n);

% Tính đạo hàm riêng thủ công
for i = 2:m-1
    for j = 2:n-1
        % Trích vùng 3x3
        region = I(i-1:i+1, j-1:j+1);
        Gx(i,j) = sum(sum(region .* Gx_mask));
        Gy(i,j) = sum(sum(region .* Gy_mask));
        G(i,j) = sqrt(Gx(i,j)^2 + Gy(i,j)^2);
    end
end

% Chuẩn hóa
G = uint8(255 * mat2gray(G));

% Hiển thị
figure;
subplot(1,3,1); imshow(uint8(I)); title('Ảnh gốc');
subplot(1,3,2); imshow(uint8(Gx)); title('Gradient theo X (Sobel)');
subplot(1,3,3); imshow(G); title('Biên Sobel');
