function filtered_image = butterworthFilter(input_image, filter_type, D0, n, R)
% BUTTERWORTHFILTER  Lọc ảnh dùng bộ lọc Butterworth và hiển thị từng bước xử lý.
%
%   filtered_image = butterworthFilter(input_image, filter_type, D0, n, R)
%
%   Tham số đầu vào:
%     input_image : Ảnh đầu vào (có thể là đường dẫn, uint8, double, RGB, hoặc xám)
%     filter_type : 'lowpass' hoặc 'highpass'
%     D0          : Tần số cắt (cutoff frequency)
%     n           : Bậc của bộ lọc Butterworth
%     R           : Bán kính minh họa vùng trung tâm trong phổ
%
%   Tham số đầu ra:
%     filtered_image : Ảnh sau khi lọc, chuẩn hóa [0,1]

    % --- 1. Đọc ảnh nếu cần ---
    if ischar(input_image) || isstring(input_image)
        input_image = imread(input_image);
    end

    % --- 2. Chuyển về ảnh xám ---
    if size(input_image, 3) == 3
        I = rgb2gray(input_image);
    else
        I = input_image;
    end
    I = im2double(I);
    [M, N] = size(I);

    figure('Name', 'Butterworth Filter Visualization', 'NumberTitle', 'off', ...
           'Units', 'normalized', 'Position', [0.05 0.1 0.9 0.75]);

    % === (1) ẢNH GỐC ===
    subplot(2,3,1);
    imshow(I, []);
    title('Ảnh gốc', 'FontSize', 11, 'FontWeight', 'bold');

    % === (2) BIẾN ĐỔI FOURIER ===
    F = fft2(I);
    Fs = fftshift(F);
    subplot(2,3,2);
    imshow(log(1+abs(Fs)), []);
    title('Phổ tần số log|F(u,v)|', 'FontSize', 11, 'FontWeight', 'bold');

    % === (3) TẠO MẶT NẠ BUTTERWORTH ===
    [u, v] = meshgrid(-floor(N/2):(ceil(N/2)-1), -floor(M/2):(ceil(M/2)-1));
    D = sqrt(u.^2 + v.^2);

    % Bộ lọc thông thấp cơ bản
    H_LPF = 1 ./ (1 + (D ./ D0).^(2*n));

    % Chọn loại lọc
    if strcmpi(filter_type, 'lowpass')
        H = H_LPF;
        filter_name = sprintf('Butterworth thông thấp (D₀ = %d, n = %d)', D0, n);
    elseif strcmpi(filter_type, 'highpass')
        H = 1 - H_LPF;
        filter_name = sprintf('Butterworth thông cao (D₀ = %d, n = %d)', D0, n);
    else
        error('Loại bộ lọc không hợp lệ. Chọn ''lowpass'' hoặc ''highpass''.');
    end

    subplot(2,3,3);
    imshow(H, []);
    title('Mặt nạ Butterworth', 'FontSize', 11, 'FontWeight', 'bold');

    % === (4) HIỂN THỊ VÙNG R TRONG PHỔ ===
    mask_R = zeros(M, N);
    [X, Y] = meshgrid(1:N, 1:M);
    mask_R(((X - N/2).^2 + (Y - M/2).^2) <= R^2) = 1;

    freq_vis = mat2gray(log(1 + abs(Fs)));
    freq_overlay = cat(3, freq_vis, freq_vis .* (1 - mask_R), freq_vis .* (1 - mask_R));

    subplot(2,3,4);
    imshow(freq_overlay, []);
    title({['Vùng trung tâm tần số, R = ', num2str(R)]}, ...
          'FontSize', 11, 'FontWeight', 'bold');

    % === (5) ÁP DỤNG LỌC TRONG MIỀN TẦN SỐ ===
    G = H .* Fs;
    subplot(2,3,5);
    imshow(log(1 + abs(G)), []);
    title('Phổ sau khi nhân H·F', 'FontSize', 11, 'FontWeight', 'bold');

    % === (6) BIẾN ĐỔI FOURIER NGƯỢC ===
    g = real(ifft2(ifftshift(G)));
    filtered_image = mat2gray(g);

    subplot(2,3,6);
    imshow(filtered_image, []);
    title(['Ảnh sau lọc ', strrep(filter_name, 'Butterworth ', '')], ...
          'FontSize', 11, 'FontWeight', 'bold');

    sgtitle(['Bộ lọc ', filter_name], 'FontSize', 14, 'FontWeight', 'bold');
end


%% Test
Iin = imgetfile;
I = imread(Iin);
filtered_low = butterworthFilter(I, 'lowpass', 40, 2, 40);
filtered_high = butterworthFilter(I, 'highpass', 40, 2, 10);