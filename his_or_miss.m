% %% TÌM ĐIỂM GIAO NHÁNH
% 
% %% 1. Khởi tạo
% clear;
% clc;
% close all;
% 
% %% 2. Tải và chuẩn bị ảnh
% Iin = imgetfile; 
% try
%     originalImage = imread(Iin);
% catch
%     error('Lỗi: Không tìm thấy file "%s". Vui lòng kiểm tra lại tên file.', image_filename);
% end
% 
% % Tiền xử lý: chuyển ảnh thành ảnh nhị phân
% I = logical(originalImage);
% 
% % Nếu ảnh có nhiều pixel trắng hơn đen, ta giả định nền là màu trắng
% % Đảo ngược ảnh để đối tượng luôn là màu trắng (giá trị 1).
% if sum(I(:)) > (numel(I) / 2)
%     I = ~I;
%     disp('-> Đảo ngược ảnh để đảm bảo đối tượng là màu trắng.');
% end
% 
% %% 3. Thiết kế các Kernel để tìm điểm giao nhánh
% K1 = [-1 1 -1; 1 1 1; -1 -1 -1];
% K2 = [1 -1 1; -1 1 -1; 1 -1 -1];
% K3 = [-1 1 -1; -1 1 1; 1 -1 -1];
% K4 = [-1 -1 1; 1 1 -1; -1 -1 1];
% kernels_branchpoints = {K1, K2, K3, K4};
% 
% %% 4. Áp dụng Hit-or-Miss
% all_branchpoints = false(size(I));
% for i = 1:length(kernels_branchpoints)
%     kernel_base = kernels_branchpoints{i};
%     for rotation = 0:3 % Xoay mỗi kernel 4 lần
%         rotated_kernel = rot90(kernel_base, rotation);
%         branchpoints_i = hit_or_miss(I, rotated_kernel);
%         all_branchpoints = all_branchpoints | branchpoints_i;
%     end
% end
% 
% %% 5. Hiển thị kết quả
% figure('Name', 'Ứng dụng tìm điểm giao nhánh', 'NumberTitle', 'off', 'WindowState', 'maximized');
% 
% subplot(1,2,1);
% imshow(I);
% title('Original Image');
% 
% marker_se = strel('disk', 1);
% visible_markers = imdilate(all_branchpoints, marker_se);
% overlayImage = imoverlay(I, visible_markers, 'cyan');
% subplot(1, 2, 2);
% imshow(overlayImage);
% title('Branchpoints (Blue points)');

% %% TÌM ĐIỂM CUỐI CỦA CÁC ĐƯỜNG
% %% 1. Khởi tạo
% clear;
% clc;
% close all;
% 
% %% 2. Tải và chuẩn bị ảnh
% image_filename = 'color\t13.tif'; 
% try
%     originalImage = imread(image_filename);
% catch
%     error('Lỗi: Không tìm thấy file "%s". Vui lòng kiểm tra lại tên file.', image_filename);
% end
% 
% % Chuyển ảnh thành ảnh nhị phân
% I = logical(originalImage);
% 
% % Nếu ảnh có nhiều pixel trắng hơn đen, ta giả định nền là màu trắng
% % Đảo ngược ảnh để đối tượng luôn là màu trắng (giá trị 1).
% if sum(I(:)) > (numel(I) / 2)
%     I = ~I;
%     disp('-> Đảo ngược ảnh để đảm bảo đối tượng là màu trắng.');
% end
% 
% %% 3. Thiết kế các Kernel
% K1 = [0 0 0; 0 1 0; -1 1 -1];
% K2 = [0 0 0; -1 1 0; 1 -1 0];
% K3 = [-1 0 0; 1 1 0; -1 0 0];
% K4 = [1 -1 0; -1 1 0; 0 0 0]; 
% K5 = [-1 1 -1; 0 1 0; 0 0 0]; 
% K6 = [0 -1 1; 0 1 -1; 0 0 0]; 
% K7 = [0 0 -1; 0 1 1; 0 0 -1]; 
% K8 = [0 0 0; 0 1 -1; 0 -1 1]; 
% kernels_endpoints = {K1, K2, K3, K4, K5, K6, K7, K8};
% 
% %% 4. Áp dụng Hit-or-Miss cho từng kernel
% all_endpoints = false(size(I));
% for i = 1:length(kernels_endpoints)
%     endpoints_i = hit_or_miss(I, kernels_endpoints{i});
%     all_endpoints = all_endpoints | endpoints_i;
% end
% 
% %% 5. Hiển thị kết quả
% figure('Name', 'Ứng dụng tìm điểm cuối', 'NumberTitle', 'off', 'WindowState', 'maximized');
% subplot(1,2,1);
% imshow(I);
% title('Original Image');
% 
% marker_se = strel('disk', 1);
% visible_markers = imdilate(all_endpoints, marker_se);
% overlayImage = imoverlay(I, visible_markers, 'red');
% subplot(1, 2, 2);
% imshow(overlayImage);
% title('Endpoints (Red points)');

%% LÀM MỎNG VÀ XƯƠNG HÓA
%% 1. Khởi tạo
clear;
clc;
close all;

%% 2. Tải và chuẩn bị ảnh
image = 'color\t13.tif'; 
try
    originalImage = imread(image);
catch
    error('Lỗi: Không tìm thấy file "%s". Vui lòng kiểm tra lại tên file.', image);
end

% Tiền xử lý: chuyển ảnh thành ảnh nhị phân
I = logical(originalImage);

% Nếu ảnh có nhiều pixel trắng hơn đen, ta giả định nền là màu trắng
% Đảo ngược ảnh để đối tượng luôn là màu trắng (giá trị 1).
if sum(I(:)) > (numel(I) / 2)
    I = ~I;
    disp('-> Đảo ngược ảnh để đảm bảo đối tượng là màu trắng.');
end

%% 3. Thiết kế các Kernel cho thuật toán làm mỏng
% Thuật toán làm mỏng của Guo và Hall sử dụng một bộ 8 kernel
K1 = [0 0 0; -1 1 -1; 1 1 1];
K2 = [-1 0 0; 1 1 0; 1 1 -1];
K3 = [1 -1 0; 1 1 0; 1 -1 0];
K4 = [1 1 -1; 1 1 0; -1 0 0];
K5 = [1 1 1; -1 1 -1; 0 0 0];
K6 = [-1 1 1; 0 1 1; 0 0 -1];
K7 = [0 -1 1; 0 1 1; 0 -1 1];
K8 = [0 0 -1; 0 1 1; -1 1 1];
kernels_thinning = {K1, K2, K3, K4, K5, K6, K7, K8};

%% 4. Thực hiện thuật toán
thinningImage = I;
previousImage = zeros(size(I));

iter = 0;
while ~isequal(thinningImage, previousImage)

    previousImage = thinningImage;
    for i = 1:length(kernels_thinning)
        removable_points = hit_or_miss(thinningImage, kernels_thinning{i});

        % Trừ các điểm đó khỏi ảnh hiện tại (A_new = A_old - HitMissResult)
        thinningImage = thinningImage & ~removable_points;
    end
    iter = iter + 1;
end

%% 5. Hiển thị kết quả
figure('Name', 'Ứng dụng làm mỏng', 'NumberTitle', 'off', 'WindowState', 'maximized');

subplot(1, 2, 1);
imshow(I);
title('Original Image');

subplot(1, 2, 2);
imshow(thinningImage);
title('Skeletonization');



%% HIT-OR-MISS
% -------------------------------------------------------------------------
function result = hit_or_miss(image, kernel)
    se_hit = strel('arbitrary', kernel == 1);
    se_miss = strel('arbitrary', kernel == 0);
    erosion_hit = erosion(image, se_hit);
    erosion_miss = erosion(~image, se_miss);
    result = erosion_hit & erosion_miss;
end

%% EROSION
% -------------------------------------------------------------------------
function erodedImage = erosion(binaryImage, se)
%   Input:
%   - binaryImage: Ảnh nhị phân đầu vào.
%   - se: Phần tử cấu trúc.
%   Output:
%   - erodedImage: Ảnh sau khi thực hiện phép co.

    % Lấy kích thước của ảnh và phần tử cấu trúc
    [imgRows, imgCols] = size(binaryImage);
    se_neighborhood = se.Neighborhood;
    [seRows, seCols] = size(se_neighborhood);
    
    % Tìm tọa độ của điểm gốc trong SE
    se_center_row = floor((seRows + 1) / 2);
    se_center_col = floor((seCols + 1) / 2);

    % Khởi tạo ảnh kết quả với toàn bộ pixel là 0 (nền)
    erodedImage = false(imgRows, imgCols);

    % Duyệt qua từng pixel của ảnh gốc
    for r = se_center_row : imgRows - (seRows - se_center_row)
        for c = se_center_col : imgCols - (seCols - se_center_col)
            
            % Trích xuất vùng lân cận (ROI - Region of Interest) trên ảnh có cùng kích thước với SE
            roi = binaryImage(r - (se_center_row - 1) : r + (seRows - se_center_row), ...
                              c - (se_center_col - 1) : c + (seCols - se_center_col));
            
            % Kiểm tra điều kiện khớp của phép co
            % Tất cả các pixel 1 của SE phải nằm trên pixel 1 của ảnh
            mismatch = se_neighborhood & ~roi;
            
            % Nếu các điểm 1 đều khớp (sum(mismatch(:))==0) thì pixel trung tâm của kết quả sẽ là 1.
            if sum(mismatch(:)) == 0
                erodedImage(r, c) = true;
            end
        end
    end
end