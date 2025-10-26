% --- Bước 1: Đọc và chuyển ảnh sang mức xám
Iin = imgetfile;
I = imread(Iin);
[r, c, p] = size(I);
if p > 1
    Igray = rgb2gray(I);
else
    Igray = I;
end
I = im2double(Igray);

% --- Bước 2: Laplace of Gaussian ---
hsize = 9;    % kích thước mặt nạ (phải là số lẻ)
sigma = 1.5;   % độ lệch chuẩn Gaussian
n = floor(hsize/2);            % bán kính
G = zeros(hsize, hsize);
LoG = zeros(hsize, hsize);
for i = -n:n
    for j = -n:n
        G(i+n+1, j+n+1) = exp(-(i^2 + j^2) / (2*sigma^2));
        LoG(i+n+1, j+n+1) = ((i.^2 + j.^2 - 2*sigma^2) ./ sigma^4)...
            .* exp(-(i.^2 + j.^2) / (2*sigma^2));
    end
end

% Chuẩn hóa (đảm bảo tổng trọng số gần 0) ----------
% Việc trừ mean đảm bảo tổng = 0 (không thay đổi độ sáng trung bình)
LoG = LoG - mean(LoG(:));


% --- Bước 3: Lọc ảnh ---
% Mở rộng ảnh
Iexpand = zeros(r + 2*n, c + 2*n);

% --- Chèn ảnh gốc vào giữa ---
Iexpand(n+1:n+r, n+1:n+c) = I;
% trái và phải
Iexpand(n+1:n+r, 1:n)       = repmat(I(:,1), 1, n);
Iexpand(n+1:n+r, c+n+1:end) = repmat(I(:,end), 1, n);
% trên và dưới
Iexpand(1:n, :)       = repmat(Iexpand(n+1,:), n, 1);
Iexpand(r+n+1:end, :) = repmat(Iexpand(r+n,:), n, 1);

% --- Tích chập ---
I_log = zeros(r, c);
for i = 1:r
    for j = 1:c
        % Lấy vùng con (cửa sổ) kích thước hsize x hsize quanh điểm (i,j)
        region = Iexpand(i:i+2*n, j:j+2*n);
        
        % Nhân từng phần tử với bộ lọc G và cộng lại
        I_log(i, j) = sum(sum(region .* LoG));
    end
end

% --- Bước 4: Phát hiện biên bằng zero-crossing ---
threshold = 0.2;
BW = zeros(size(I_log));
for i = 2:size(I_log,1)-1
    for j = 2:size(I_log,2)-1
        % Lấy vùng 3x3 quanh điểm (i,j)
        region = I_log(i-1:i+1, j-1:j+1);
        % Nếu giá trị trong vùng đổi dấu (âm ↔ dương) và biên độ > ngưỡng → biên
        if (max(region(:)) > 0 && min(region(:)) < 0 && ...
                (max(region(:)) - min(region(:))) > threshold)
            BW(i,j) = 1;
        end
    end
end

% --- Hiển thị kết quả ---
figure;
subplot(1,3,1); imshow(Iin); title('Original image');
subplot(1,3,2); imshow(uint8(I_log), []); title('Image after LoG filter');
subplot(1,3,3); imshow(BW); title('Pad Image');