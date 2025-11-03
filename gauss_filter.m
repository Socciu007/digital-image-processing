function g_final_uint8 = gaussianFilterShow(img_input, filter_kind, D0, P_factor)
%   Input:
%     img_input   - đường dẫn hoặc ma trận ảnh (RGB hoặc xám)
%     filter_kind - 'lowpass' hoặc 'highpass'
%     D0          - tần số cắt (cutoff frequency), ví dụ 40
%     P_factor    - hệ số padding (mặc định = 2)
%   Output:
%     g_final_uint8 - ảnh kết quả sau lọc (uint8)

    %% --- Mặc định ---
    if nargin < 3, D0 = 40; end
    if nargin < 4, P_factor = 2; end

    %% --- Đọc và chuyển sang ảnh xám ---
    if ischar(img_input) || isstring(img_input)
        Iorig = imread(img_input);
    else
        Iorig = img_input;
    end

    if size(Iorig,3) == 3
        f_gray = rgb2gray(Iorig);
    else
        f_gray = Iorig;
    end

    f = im2double(f_gray);
    [M, N] = size(f);

    %% --- Zero-padding ---
    P = P_factor * M;
    Q = P_factor * N;
    fp = zeros(P, Q);
    fp(1:M,1:N) = f;

    %% --- Dịch tâm ảnh ---
    [x, y] = meshgrid(0:Q-1, 0:P-1);
    fc = fp .* (-1).^(x + y);

    %% --- Biến đổi Fourier ---
    F = fft2(fc);

    %% --- Tạo bộ lọc Gaussian ---
    [u, v] = meshgrid(0:Q-1, 0:P-1);
    u0 = floor(Q/2);
    v0 = floor(P/2);
    D = sqrt((u - u0).^2 + (v - v0).^2);

    if strcmpi(filter_kind, 'lowpass')
        H = exp(-(D.^2) / (2*(D0^2)));
        filter_name = sprintf('Gaussian Thông Thấp (D₀ = %d)', D0);
    elseif strcmpi(filter_kind, 'highpass')
        H = 1 - exp(-(D.^2) / (2*(D0^2)));
        filter_name = sprintf('Gaussian Thông Cao (D₀ = %d)', D0);
    else
        error('filter_kind phải là ''lowpass'' hoặc ''highpass''.');
    end

    %% --- Áp dụng lọc ---
    G = H .* F;

    %% --- Biến đổi ngược ---
    gc = ifft2(G);
    gp = real(gc) .* (-1).^(x + y);
    g = gp(1:M, 1:N);
    g_normalized = mat2gray(g);
    g_final_uint8 = im2uint8(g_normalized);

    %% --- Hiển thị toàn bộ các bước ---
    figure('Name', ['Bộ lọc ', filter_name], ...
           'NumberTitle','off','Units','normalized','Position',[0.05 0.05 0.9 0.8]);

    tiledlayout(3,4,'TileSpacing','compact','Padding','compact');

    nexttile; imshow(f_gray, []); title('1. Ảnh gốc (xám)');
    nexttile; imshow(fp, []); title(sprintf('2. Zero-padded (%dx%d)',P,Q));
    nexttile; imshow(fc, []); title('3. Ảnh sau dịch tâm (-1)^{x+y}');
    nexttile; imshow(log(1 + abs(F)), []); title('4. log|F(u,v)|');

    nexttile; imshow(H, []); title('5. Mặt nạ lọc');
    nexttile; plot(H(v0,:), 'b','LineWidth',1.5);
        grid on; xlabel('u'); ylabel('H');
        title('6. Mặt cắt H(u,v) qua tâm');

    nexttile; imshow(log(1 + abs(G)), []); title('7. log|G(u,v)| sau khi nhân H');
    nexttile; imshow(real(gc), []); title('8. Ảnh sau IFFF (Phần thực)');

    nexttile; imshow(gp, []); title('9. Ảnh sau dịch tâm ngược');
    nexttile; imshow(g_final_uint8, []); title('10. Ảnh kết quả');

    sgtitle(['LỌC ẢNH BẰNG BỘ LỌC ', upper(filter_kind), ...
             ' GAUSSIAN - D₀ = ', num2str(D0)], ...
             'FontSize', 14, 'FontWeight','bold');

    %% --- Hiển thị so sánh ảnh ---
    figure('Name','So sánh ảnh trước và sau lọc','NumberTitle','off');
    subplot(1,2,1); imshow(f_gray, []); title('Ảnh gốc (xám)');
    subplot(1,2,2); imshow(g_final_uint8, []); title(['Ảnh sau lọc ', filter_name]);
end

%% test
gaussianFilterShow('color/t3.tif', 'lowpass', 40, 2);
gaussianFilterShow('color/t3.tif', 'highpass', 40, 2);