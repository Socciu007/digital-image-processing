function filtered_img = idealFilterDemo(input_image, mode, Dcut)
%   Đầu vào:
%       input_image : Ảnh đầu vào (đường dẫn hoặc ma trận)
%       mode        : 'low' hoặc 'high'
%       Dcut        : Bán kính cắt (cutoff radius)
%   Đầu ra:
%       filtered_img : Ảnh đã được lọc (double, chuẩn hóa 0–1)

    %% --- 1. Đọc ảnh ---
    if ischar(input_image) || isstring(input_image)
        img = imread(input_image);
    else
        img = input_image;
    end

    img = im2double(img);
    if size(img,3) == 3
        gray = rgb2gray(img);
    else
        gray = img;
    end
    [M, N] = size(gray);

    %% --- 2. Zero-padding ---
    P = 2*M;
    Q = 2*N;
    fpad = zeros(P, Q);
    fpad(1:M, 1:N) = gray;

    %% --- 3. Dịch tâm (multiply by (-1)^(x+y)) ---
    [x, y] = meshgrid(0:Q-1, 0:P-1);
    center_mask = (-1).^(x + y);
    f_centered = fpad .* center_mask;

    %% --- 4. Biến đổi Fourier ---
    F = fft2(f_centered);
    F_mag = log(1 + abs(F));

    %% --- 5. Tạo mặt nạ bộ lọc H(u,v) ---
    [u, v] = meshgrid(0:Q-1, 0:P-1);
    uc = Q/2;
    vc = P/2;
    D = sqrt((u - uc).^2 + (v - vc).^2);

    if strcmpi(mode, 'low')
        H = double(D <= Dcut);
        filter_name = sprintf('Ideal Low-pass (R = %d)', Dcut);
    elseif strcmpi(mode, 'high')
        H = double(D > Dcut);
        filter_name = sprintf('Ideal High-pass (R = %d)', Dcut);
    else
        error('Chế độ không hợp lệ. Chọn "low" hoặc "high".');
    end

    %% --- 6. Áp dụng lọc trong miền tần số ---
    G = H .* F;
    G_mag = log(1 + abs(G));

    %% --- 7. Biến đổi ngược ---
    f_all = real(ifft2(G));

    %% --- 8. Dịch ngược và cắt lại ---
    f_uncentered = f_all .* center_mask;
    f_result = f_uncentered(1:M, 1:N);
    filtered_img = mat2gray(f_result);

    %% --- 9. HIỂN THỊ TỪNG BƯỚC ---
    figure('Name', ['Ideal Filter Demo - ' upper(mode)], ...
           'NumberTitle', 'off', 'Units', 'normalized', 'Position', [0.05 0.05 0.9 0.8]);

    subplot(3,3,1);
    imshow(gray, []);
    title('1. Ảnh gốc (grayscale)');

    subplot(3,3,2);
    imshow(fpad, []);
    title(sprintf('2. Zero-padded (%dx%d)', P, Q));

    subplot(3,3,3);
    imshow(f_centered, []);
    title('3. Ảnh sau dịch tâm (-1)^{x+y}');

    subplot(3,3,4);
    imshow(F_mag, []);
    title('4. Phổ |F(u,v)| (log scale)');

    subplot(3,3,5);
    imshow(H, []);
    title(['5. Mặt nạ bộ lọc H(u,v) - ', filter_name]);

    subplot(3,3,6);
    imshow(G_mag, []);
    title('6. Phổ sau khi nhân H·F (log scale)');

    subplot(3,3,7);
    imshow(real(ifft2(G)), []);
    title('7. Kết quả IFFT (phần thực)');

    subplot(3,3,8);
    imshow(f_uncentered, []);
    title('8. Sau dịch ngược (-1)^{x+y}');

    subplot(3,3,9);
    imshow(filtered_img, []);
    title('9. Ảnh kết quả cuối cùng');

    sgtitle(filter_name, 'FontSize', 14, 'FontWeight', 'bold');
end


%% Test
idealFilterDemo('color\t2.tif', 'high', 60);
idealFilterDemo('color\t2.tif', 'low', 60);