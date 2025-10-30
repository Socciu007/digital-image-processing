function filtered_image = butterworthFilter(input_image, filter_type, D0, n, R)
%   Tham số đầu vào:
%     input_image: Ảnh đầu vào (có thể là đường dẫn, uint8 hoặc double).
%     filter_type: 'lowpass' hoặc 'highpass'.
%     D0: Tần số cắt (cutoff frequency).
%     n: Bậc của bộ lọc Butterworth.
%     R: Bán kính minh họa vùng trung tâm.
%
%   Tham số đầu ra:
%     filtered_image: Ảnh đã được lọc.

    % --- Nếu input là đường dẫn file, đọc ảnh ---
    if ischar(input_image) || isstring(input_image)
        input_image = imread(input_image);
    end

    % --- Chuyển về ảnh xám nếu là ảnh màu ---
    if size(input_image, 3) == 3
        I = rgb2gray(input_image);
    else
        I = input_image;
    end

    % --- Đảm bảo kiểu double để tính toán chính xác ---
    I = im2double(I);

    % === Hiển thị ảnh gốc ===
    figure;
    subplot(2,3,1);
    imshow(I, []);
    title('Ảnh gốc (xám)');

    % === 1. Biến đổi Fourier ===
    F = fft2(I);
    Fs = fftshift(F);
    subplot(2,3,2);
    imshow(log(1+abs(Fs)), []);
    title('Phổ tần số (log scale)');

    % === 2. Tạo bộ lọc Butterworth ===
    [M, N] = size(I);
    u = 0:(M-1);
    v = 0:(N-1);
    idx_u = find(u > M/2); u(idx_u) = u(idx_u) - M;
    idx_v = find(v > N/2); v(idx_v) = v(idx_v) - N;
    [V, U] = meshgrid(v, u);
    D = sqrt(U.^2 + V.^2);

    % Bộ lọc thông thấp Butterworth cơ bản
    H_LPF_base = 1 ./ (1 + (D ./ D0).^(2*n));

    % Loại lọc
    if strcmpi(filter_type, 'highpass')
        H = H_LPF_base;
        filter_name = 'highpass';
    elseif strcmpi(filter_type, 'lowpass')
        H = 1 - H_LPF_base;
        filter_name = 'lowpass';
    else
        error('Loại bộ lọc không hợp lệ. Vui lòng chọn ''lowpass'' hoặc ''highpass''.');
    end

    % --- 3. Mặt nạ Butterworth ---
    subplot(2,3,3);
    imshow(fftshift(H), []);
    title('Mặt nạ Butterworth');

    % === 4. Hiển thị vùng bán kính R trên phổ ===
    mask_R = zeros(size(I));
    centerU = round(M/2);
    centerV = round(N/2);
    [X, Y] = meshgrid(1:N, 1:M);
    mask_R(((X - centerV).^2 + (Y - centerU).^2) <= R^2) = 1;

    % Overlay vùng R lên phổ tần số
    freq_vis = mat2gray(log(1+abs(Fs)));
    freq_overlay = freq_vis;
    freq_overlay(:,:,2) = freq_vis .* (1 - mask_R);
    freq_overlay(:,:,3) = freq_vis .* (1 - mask_R);

    subplot(2,3,4);
    imshow(freq_overlay, []);
    title({['Vùng trung tâm bán kính R = ', num2str(R)]});

    % === 5. Áp dụng lọc trong miền tần số ===
    G_filtered = H .* Fs;

    subplot(2,3,5);
    imshow(log(1+abs(G_filtered)), []);
    title('Phổ sau khi lọc');

    % === 6. Biến đổi ngược Fourier ===
    g_filtered = real(ifft2(ifftshift(G_filtered)));

    % === 7. Chuẩn hóa kết quả ===
    filtered_image = mat2gray(g_filtered);

    subplot(2,3,6);
    imshow(filtered_image, []);
    title({['Ảnh sau khi lọc ' filter_name ' Butterworth'], ...
           ['D₀ = ', num2str(D0), ', n = ', num2str(n)]});
end


%% Test
Iin = imgetfile;
I = imread(Iin);
filtered_low = butterworthFilter(I, 'lowpass', 40, 2, 10);
filtered_high = butterworthFilter(I, 'highpass', 20, 2, 10);