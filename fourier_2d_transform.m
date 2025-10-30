clear; close all; clc;

%% --------- Tham số đầu vào (chỉnh tại đây) --------------
img_path = 'color\t2.tif';        % ảnh mẫu
filter_type = 'butterworth';      % 'ideal', 'butterworth', 'gaussian'
filter_kind = 'bandpass';         % 'lowpass', 'highpass' hoặc 'bandpass'
D0 = 30;                          % cutoff cho low/high pass
D0_low = 10;                      % lower cutoff cho bandpass
D0_high = 50;                     % upper cutoff cho bandpass
n_butt = 2;                       % bậc Butterworth
P_factor = 2;                     % P = P_factor*M, Q = P_factor*N

%% --------- 1) Đọc ảnh và chuyển sang double ----------------
f_orig = imread(img_path);
if size(f_orig,3) == 3
    f_gray = rgb2gray(f_orig);
else
    f_gray = f_orig;
end
f = im2double(f_gray);
[M, N] = size(f);

%% --------- 2) Zero-pad ảnh tới (P,Q)
P = P_factor * M;
Q = P_factor * N;
fp = zeros(P, Q);
fp(1:M,1:N) = f;

%% --------- 3) Dịch tâm phổ: f_c(x,y) = f(x,y)*(-1)^(x+y)
[x, y] = meshgrid(0:Q-1, 0:P-1);
center_mask = (-1).^(x + y);
fc = fp .* center_mask;

%% --------- 4) Biến đổi Fourier 2D
F = fft2(fc);
F_shift = fftshift(F);

%% --------- 5) Tạo bộ lọc H(u,v)
[u, v] = meshgrid(0:Q-1, 0:P-1);
u0 = floor(Q/2);
v0 = floor(P/2);
D = sqrt((u - u0).^2 + (v - v0).^2);

switch lower(filter_kind)
    case 'lowpass'
        H = create_lowpass(filter_type, D, D0, n_butt);
    case 'highpass'
        H = create_highpass(filter_type, D, D0, n_butt);
    case 'bandpass'
        H_low = create_lowpass(filter_type, D, D0_high, n_butt);
        H_high = create_highpass(filter_type, D, D0_low, n_butt);
        H = H_low .* H_high;
    otherwise
        error('filter_kind không hợp lệ');
end
H_shift = fftshift(H);

%% --------- 6) Nhân phổ: G(u,v) = H(u,v) * F(u,v)
G = H .* F;
G_shift = fftshift(G);

%% --------- 7) Biến đổi ngược và dịch ngược
gc = ifft2(G);
gp = real(gc) .* center_mask;
g = gp(1:M, 1:N);

%% --------- 8) Hiển thị tất cả trong 1 Figure
figure('Name','Tổng hợp các bước Fourier Filtering','NumberTitle','off');
tiledlayout(3,3, 'Padding', 'compact', 'TileSpacing', 'compact');

% (1) Ảnh gốc
nexttile; imshow(f_gray, []); title('Ảnh gốc (xám)');

% (2) Zero-padded
nexttile; imshow(fp, []); title(sprintf('Zero-padded (%dx%d)',P,Q));

% (3) Dịch tâm
nexttile; imshow(fc, []); title('Dịch tâm (-1)^{x+y}');

% (4) Phổ ban đầu
nexttile; imshow(log(1+abs(F)), []); title('log|F(u,v)| (shifted)');

% (5) Mặt nạ H(u,v)
nexttile; imshow(H, []); 
title(sprintf('Bộ lọc %s %s', filter_type, filter_kind));

% (6) Phổ sau nhân H
nexttile; imshow(log(1+abs(G)), []); 
title('log|G(u,v)| sau nhân H');

% (7) IFFT và dịch ngược
nexttile; imshow(gp, []); title('Sau ifft & dịch ngược');

% (8) Ảnh cắt lại
nexttile; imshow(g, []); 
title(sprintf('Ảnh sau lọc (%s)', filter_kind));

sgtitle(sprintf('Biến đổi Fourier 2D - %s %s (D₀ = %d, n = %d)', ...
    filter_type, filter_kind, D0, n_butt), 'FontSize', 12, 'FontWeight', 'bold');

%% ======= Hàm con =======
function H = create_lowpass(type, D, D0, n)
    switch lower(type)
        case 'ideal'
            H = double(D <= D0);
        case 'butterworth'
            H = 1 ./ (1 + (D ./ D0).^(2*n));
        case 'gaussian'
            H = exp(-(D.^2) ./ (2*(D0^2)));
        otherwise
            error('Loại bộ lọc không hợp lệ');
    end
end

function H = create_highpass(type, D, D0, n)
    switch lower(type)
        case 'ideal'
            H = double(D > D0);
        case 'butterworth'
            H = 1 ./ (1 + (D0 ./ (D + eps)).^(2*n));
        case 'gaussian'
            H = 1 - exp(-(D.^2) ./ (2*(D0^2)));
        otherwise
            error('Loại bộ lọc không hợp lệ');
    end
end
