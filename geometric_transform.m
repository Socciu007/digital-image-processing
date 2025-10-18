clc; clear; close all;
I = imread('color\t21.jpg');
% Crop image
I = im2gray(I);
%% Nearest Neighbor Interpolation
function J = nearest(I, scale)
    % --- Lấy kích thước ảnh gốc và kiểu dữ liệu ---
    [rows_orig, cols_orig] = size(I);
    input_class = class(I);

    % --- Tính toán kích thước ảnh mới ---
    rows_new = round(rows_orig * scale);
    cols_new = round(cols_orig * scale);
    
    % Xử lý trường hợp kích thước mới có thể trở thành 0 nếu tỉ lệ quá nhỏ
    if rows_new == 0 || cols_new == 0
        J = cast([], input_class);
        warning('nearest:ZeroDimension', 'Kích thước ảnh sau khi thay đổi tỉ lệ trở thành 0. Trả về ảnh rỗng.');
        return;
    end

    J = zeros(rows_new, cols_new, input_class);
    
    y_scale_ratio = rows_new / rows_orig;
    x_scale_ratio = cols_new / cols_orig;

    % --- Vòng lặp duyệt qua từng điểm ảnh trong ảnh đầu ra ---
    for r_new = 1:rows_new
        for c_new = 1:cols_new
            orig_row = round((r_new - 0.5) / y_scale_ratio + 0.5);
            orig_col = round((c_new - 0.5) / x_scale_ratio + 0.5);

            orig_row = max(1, min(orig_row, rows_orig));
            orig_col = max(1, min(orig_col, cols_orig));
            
            % --- Gán giá trị điểm ảnh ---
            J(r_new, c_new) = I(orig_row, orig_col);
        end
    end

end
J = nearest(I, 3);
% J = imresize(I, 3, "nearest");
figure;
% subplot(2,2,1), imshow(I), title('Original');
subplot(2,2,2), imshow(J), title('Nearest Neighbor x3');
% subplot(1,4,1), imshow(I), axis image off, title('Original');
% subplot(1,4,2), imshow(J), axis image off, title('Nearest Neighbor');

%% Bilinear Interpolation
function J1 = bilinear(I, scale)
    [rows, cols] = size(I);
    new_rows = round(rows * scale);
    new_cols = round(cols * scale);
    J1 = zeros(new_rows, new_cols, 'uint8');
    I = double(I);
    
    for r = 1:new_rows
        for c = 1:new_cols
            x = (r - 0.5) / scale + 0.5;
            y = (c - 0.5) / scale + 0.5;
            
            x1 = floor(x); x2 = ceil(x);
            y1 = floor(y); y2 = ceil(y);
            
            % Giữ trong phạm vi
            x1 = max(1, min(x1, rows));
            x2 = max(1, min(x2, rows));
            y1 = max(1, min(y1, cols));
            y2 = max(1, min(y2, cols));
            
            % Trọng số
            dx = x - x1;
            dy = y - y1;
            
            % Công thức nội suy tuyến tính 2D
            J1(r, c) = (1-dx)*(1-dy)*I(x1,y1) + dx*(1-dy)*I(x2,y1) + ...
                      (1-dx)*dy*I(x1,y2) + dx*dy*I(x2,y2);
        end
    end
    J1 = uint8(J1);
end

J1 = bilinear(I, 3);
% J1 = imresize(I, 3, "bilinear");
subplot(2,2,3), imshow(J1), title('bilinear x3');
% subplot(1,4,3), imshow(J1), axis image off, title('Bilinear');

%% Bicubic Interpolation
function J2 = bicubic(I, scale)
    [rows, cols] = size(I);
    new_rows = round(rows * scale);
    new_cols = round(cols * scale);
    J2 = zeros(new_rows, new_cols);
    I = double(I);

    % Hàm trọng số bicubic
    function w = cubic_weight(t)
        a = -0.5; % hệ số thông dụng (Catmull-Rom)
        t = abs(t);
        if t <= 1
            w = (a + 2)*t^3 - (a + 3)*t^2 + 1;
        elseif t < 2
            w = a*t^3 - 5*a*t^2 + 8*a*t - 4*a;
        else
            w = 0;
        end
    end

    for r = 1:new_rows
        for c = 1:new_cols
            x = (r - 0.5) / scale + 0.5;
            y = (c - 0.5) / scale + 0.5;
            x1 = floor(x);
            y1 = floor(y);
            sumVal = 0;
            sumWeight = 0;
            
            for m = -1:2
                for n = -1:2
                    xm = x1 + m;
                    yn = y1 + n;
                    if xm >= 1 && xm <= rows && yn >= 1 && yn <= cols
                        w = cubic_weight(x - xm) * cubic_weight(y - yn);
                        sumVal = sumVal + I(xm, yn) * w;
                        sumWeight = sumWeight + w;
                    end
                end
            end
            
            if sumWeight ~= 0
                J2(r, c) = sumVal / sumWeight;
            end
        end
    end
    J2 = uint8(J2);
end

J2 = bicubic(I, 2);
% J2 = imresize(I, 3, "bicubic");
subplot(2,2,4), imshow(J2), title('bicubic x3');
% subplot(1,4,4), imshow(J2), axis image off, title('Bicubic');

