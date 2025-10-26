%% Histogram Equalization
function I_eq = MyHistEqualization(I)
    if size(I,3) == 3
        I = rgb2gray(I); % Convert to gray image
    end
    [M, N] = size(I);
    L = 256;
    I = double(I);

    % Histogram
    h = imhist(uint8(I));
    p = h / (M * N);

    % Cumulative Distribution Function (CDF)
    cdf = cumsum(p);

    % Mapping
    T = round((L - 1) * cdf);

    % Apply transformation
    I_eq = uint8(T(I + 1));
end

%% Test
Iin = imgetfile;
I = imread(Iin);
I = rgb2gray(I);
I_eq = MyHistEqualization(I);

figure;
subplot(2,2,1); imshow(I); title('Original Image');
subplot(2,2,2); imshow(I_eq); title('Histogram Equal Image');
subplot(2,2,3); imhist(I); title('Histogram Original');
subplot(2,2,4); imhist(I_eq); title('Histogram After Aqualization');

%% Apply HSV image
% function I_out = MyHistEqualization_RGB(I)
%     I = im2double(I);
%     % --- Covert RGB to HSV ---
%     hsv = rgb2hsv(I);
%     V = hsv(:,:,3); % Get V channel
% 
%     % --- Apply histogram equalization for V ---
%     V_eq = MyHistEqualization(uint8(V * 255));
%     V_eq = double(V_eq) / 255;
% 
%     % --- Covert RGB ---
%     hsv(:,:,3) = V_eq;
%     I_out = hsv2rgb(hsv);
% end
% 
% function I_out_rgb = MyHistEqualization_RGB_Channel(I)
%     % Đảm bảo ảnh kiểu uint8
%     if ~isa(I, 'uint8')
%         I = im2uint8(I);
%     end
% 
%     % Tách 3 kênh R, G, B
%     R = I(:,:,1);
%     G = I(:,:,2);
%     B = I(:,:,3);
% 
%     % Cân bằng từng kênh
%     R_eq = MyHistEqualization(R);
%     G_eq = MyHistEqualization(G);
%     B_eq = MyHistEqualization(B);
% 
%     % Gộp lại thành ảnh kết quả
%     I_out_rgb = cat(3, R_eq, G_eq, B_eq);
% 
%     figure;
% 
%     subplot(2,2,1); imshow(I); title('Original');
%     subplot(2,2,2); imshow(I_out_rgb); title('Equalized RGB');
%     subplot(2,2,3); imhist(I); title('Histogram Original');
%     subplot(2,2,4); imhist(I_out_rgb); title('Histogram After Aqualization');
% end
% 

% I = imread("color\t17.jpg");
% HSV = rgb2hsv(I); 
% V = HSV(:,:,2); % Get V chanel
% I_out = MyHistEqualization_RGB(I);
% I_out_rgb = MyHistEqualization_RGB_Channel(I);
% figure;
% subplot(2,2,1); imshow(I); title('Original Image');
% subplot(2,2,2); imshow(I_out); title('Equal Image (HSV- V channel)');
% subplot(2,2,3); imhist(I); title('Histogram Original');
% subplot(2,2,4); imhist(I_out); title('Histogram After Aqualization');

%% Histogram matching
function I_match = MyHistMatching(I_source, I_ref)
    % Histogram và CDF ảnh nguồn
    h_src = imhist(I_source);
    p_src = h_src / numel(I_source);
    cdf_src = cumsum(p_src);

    % Histogram và CDF ảnh mẫu
    h_ref = imhist(I_ref);
    p_ref = h_ref / numel(I_ref);
    cdf_ref = cumsum(p_ref);

    % Ánh xạ giữa CDF hai ảnh
    map = zeros(256,1,'uint8');
    for i = 1:256
        [~, idx] = min(abs(cdf_src(i) - cdf_ref));
        map(i) = idx - 1;
    end

    % Ảnh kết quả
    I_match = map(I_source + 1);
end

function I_match = MyHistMatching_Color(I_source, I_ref)
    % --- Chuyển về kiểu uint8 ---
    if ~isa(I_source, 'uint8')
        I_source = im2uint8(I_source);
    end
    if ~isa(I_ref, 'uint8')
        I_ref = im2uint8(I_ref);
    end

    % --- Nếu là ảnh màu ---
    if size(I_source, 3) == 3 && size(I_ref, 3) == 3
        R_s = I_source(:,:,1);
        G_s = I_source(:,:,2);
        B_s = I_source(:,:,3);

        R_r = I_ref(:,:,1);
        G_r = I_ref(:,:,2);
        B_r = I_ref(:,:,3);

        % --- Matching từng kênh ---
        R_m = MyHistMatching(R_s, R_r);
        G_m = MyHistMatching(G_s, G_r);
        B_m = MyHistMatching(B_s, B_r);

        % --- Gộp lại ---
        I_match = cat(3, R_m, G_m, B_m);

    else
        % --- Nếu chỉ có 1 kênh (ảnh xám) ---
        I_match = MyHistMatching(I_source, I_ref);
    end
end

%% Test histogram matching
I1 = imread('color\t20.jpg');   % Src image
I2 = imread('color\t19.jpg');        % Sample image
% I1 = im2gray(I1);
% I2 = im2gray(I2);
I_match = MyHistMatching_Color(I1, I2);

figure;
subplot(3,3,1); imshow(I1); title('Source Image');
subplot(3,3,2); imshow(I2); title('Sample Image');
subplot(3,3,3); imshow(I_match); title('Image After matching');

subplot(3,3,4); imhist(I1); title('Histogram Source');
subplot(3,3,5); imhist(I2); title('Histogram Sample');
subplot(3,3,6); imhist(I_match); title('Histtogram After Matching');

