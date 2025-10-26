function compassoperator()
% So sánh:
%   - Compass 8 hướng: Prewitt-compass, Kirsch, Robinson (0:45:315)
%   - Gradient 2 nhân: Sobel, Prewitt, Roberts
IMG_PATH     = 'color/t2.tif'; % để '' sẽ dùng cameraman.tif
PLOT_FIGS    = true;   % Vẽ figure
SAVE_PNGS    = true;   % Lưu ảnh

%% --------------- NẠP ẢNH ---------------
if isempty(IMG_PATH)
    if exist('color/t1.tif','file')
        I0 = imread('color/t1.tif');
    else
        fallback = fullfile(matlabroot,'toolbox','images','imdata','cameraman.tif');
        assert(exist(fallback,'file')==2,'Không tìm thấy color/t1.tif');
        I0 = imread(fallback);
    end
else
    assert(exist(IMG_PATH,'file')==2,'Không tìm thấy file ảnh: %s', IMG_PATH);
    I0 = imread(IMG_PATH);
end

% Ảnh xám + chuẩn hoá double [0,1]
if ndims(I0)==3
    I = rgb2gray(I0);
else
    I = I0;
end
I = im2double(I);

% Không làm trơn Gaussian
If = I;

%% --------------- COMPASS 8 HƯỚNG ---------------
[mag_pre, ~] = compass_edge8(If, 'prewitt');
[mag_kir, ~] = compass_edge8(If, 'kirsch');
[mag_rob, ~] = compass_edge8(If, 'robinson');

%% --------------- GRADIENT 2 NHÂN ---------------
[Gmag_sobel,   ~] = grad2_mag(If, 'sobel');
[Gmag_prew,    ~] = grad2_mag(If, 'prewitt');
[Gmag_roberts, ~] = grad2_mag(If, 'roberts');

%% --------------- VẼ HÌNH ---------------
if PLOT_FIGS
    tiledlayout(2,4, "Padding","compact", "TileSpacing","compact");

    % Hàng 1
    nexttile; imshow(I0,[]);                      title('Ảnh gốc');
    nexttile; imshow(I,[]);                       title('Ảnh xám (rgb2gray)');
    nexttile; imshow(my_mat2gray(Gmag_sobel));    title('Sobel');
    nexttile; imshow(my_mat2gray(Gmag_prew));     title('Prewitt');

    % Hàng 2
    nexttile; imshow(my_mat2gray(mag_pre));       title('Compass Prewitt');
    nexttile; imshow(my_mat2gray(mag_kir));       title('Compass Kirsch');
    nexttile; imshow(my_mat2gray(mag_rob));       title('Compass Robinson');
    nexttile; imshow(my_mat2gray(Gmag_roberts));  title('Roberts');
end

%% --------------- LƯU KẾT QUẢ ---------------
if SAVE_PNGS
    imwrite(I0,                                    'orig.png');
    imwrite(to_uint8(I),                           'gray.png');
    imwrite(to_uint8(my_mat2gray(mag_pre)),        'compass_prewitt_mag.png');
    imwrite(to_uint8(my_mat2gray(mag_kir)),        'compass_kirsch_mag.png');
    imwrite(to_uint8(my_mat2gray(mag_rob)),        'compass_robinson_mag.png');
    imwrite(to_uint8(my_mat2gray(Gmag_sobel)),     'sobel_mag.png');
    imwrite(to_uint8(my_mat2gray(Gmag_prew)),      'prewitt_mag.png');
    imwrite(to_uint8(my_mat2gray(Gmag_roberts)),   'roberts_mag.png');
end

%% --------------- TÓM TẮT ---------------
fprintf('\nTóm tắt:\n');
fprintf('  Compass 8 hướng: Prewitt / Kirsch / Robinson\n');
fprintf('  Gradient 2-nhân: Sobel / Prewitt / Roberts\n');
end % ===== end main =====

% ========================= HÀM PHỤ ===============================

function Y = my_conv2_same(X, K, padmode)
% Chập 2D, trả về kích thước 'same', padding replicate/zero.
    if nargin<3, padmode = 'replicate'; end
    [h,w]   = size(X);
    [kh,kw] = size(K);
    rh = floor(kh/2); rw = floor(kw/2);
    Xp = pad2d(X, rh, rw, padmode);    % padding
    Kf = rot90(K,2);                   % lật kernel (chuẩn conv)
    Y  = zeros(h,w);
    for i=1:h
        for j=1:w
            block = Xp(i:i+kh-1, j:j+kw-1);
            Y(i,j) = sum(sum(block .* Kf));
        end
    end
end

function Xp = pad2d(X, rh, rw, mode)
% Padding replicate hoặc zero.
    [h,w] = size(X);
    Xp = zeros(h+2*rh, w+2*rw);
    Xp(rh+1:rh+h, rw+1:rw+w) = X;
    if strcmpi(mode,'replicate')
        % Trên/dưới
        Xp(1:rh, rw+1:rw+w)       = repmat(X(1,:),  [rh,1]);
        Xp(rh+h+1:end, rw+1:rw+w) = repmat(X(end,:),[rh,1]);
        % Trái/phải
        Xp(:,1:rw)       = repmat(Xp(:,rw+1),  [1,rw]);
        Xp(:,rw+w+1:end) = repmat(Xp(:,rw+w),  [1,rw]);
    elseif strcmpi(mode,'zero')
        % giữ 0
    else
        error('pad2d: mode không hỗ trợ');
    end
end

function [Gmag, ThetaDeg] = grad2_mag(I, family)
% Tính |G| và hướng liên tục (deg) bằng 2 nhân (Sobel/Prewitt/Roberts).
    family = lower(string(family));
    switch family
        case "sobel"
            Gx = [ -1 0 1; -2 0 2; -1 0 1 ];
            Gy = [  1 2 1;  0 0 0; -1 -2 -1 ];
        case "prewitt"
            Gx = [ -1 0 1; -1 0 1; -1 0 1 ];
            Gy = [  1 1 1;  0 0 0; -1 -1 -1 ];
        case "roberts"
            Gx = [1 0; 0 -1];
            Gy = [0 1; -1 0];
        otherwise
            error('family phải là sobel|prewitt|roberts');
    end
    GxR = my_conv2_same(I, Gx, 'replicate');
    GyR = my_conv2_same(I, Gy, 'replicate');
    Gmag = sqrt(GxR.^2 + GyR.^2);
    ThetaDeg = atan2d(GyR, GxR); % -180..180
end

function [Gmax, ThetaDeg] = compass_edge8(I, family)
% Dò biên compass 8 hướng: lấy trị tuyệt đối lớn nhất theo hướng (không NMS).
    [K, angles] = make_compass_kernels(family);
    H = size(I,1); W = size(I,2);
    Rabs = zeros(H,W,8);
    for k=1:8
        R = my_conv2_same(I, K(:,:,k), 'replicate');
        Rabs(:,:,k) = abs(R);
    end
    [Gmax, idx] = max(Rabs, [], 3);
    ThetaDeg = angles(idx);
end

function [K, anglesDeg] = make_compass_kernels(family)
% 8 nhân 3x3 cho Prewitt/Kirsch/Robinson
    family = lower(string(family));
    anglesDeg = 0:45:315;
    K = zeros(3,3,8);

    switch family
        case "prewitt"
            K(:,:,1) = [-1 0  1; -1 0  1; -1 0  1];   % 0°
            K(:,:,2) = [ 0 1  1; -1 0  1; -1 -1  0];  % 45°
            K(:,:,3) = [ 1 1  1;  0 0  0; -1 -1 -1];  % 90°
            K(:,:,4) = [ 1 1  0;  1 0 -1;  0 -1 -1];  % 135°
            K(:,:,5) = [ 1 0 -1;  1 0 -1;  1 0 -1];   % 180°
            K(:,:,6) = [ 0 -1 -1; 1 0 -1;  1  1  0];  % 225°
            K(:,:,7) = [-1 -1 -1; 0 0  0;  1  1  1];  % 270°
            K(:,:,8) = [-1 -1  0; -1 0  1;  0  1  1]; % 315°
        case "kirsch"
            K(:,:,1) = [ 5  5  5; -3  0 -3; -3 -3 -3];
            K(:,:,2) = [ 5  5 -3;  5  0 -3; -3 -3 -3];
            K(:,:,3) = [ 5 -3 -3;  5  0 -3;  5 -3 -3];
            K(:,:,4) = [-3 -3 -3;  5  0 -3;  5  5 -3];
            K(:,:,5) = [-3 -3 -3; -3  0 -3;  5  5  5];
            K(:,:,6) = [-3 -3 -3; -3  0  5; -3  5  5];
            K(:,:,7) = [-3 -3  5; -3  0  5; -3 -3  5];
            K(:,:,8) = [-3  5  5; -3  0  5; -3 -3 -3];
        case "robinson"
            K(:,:,1) = [-1  0  1; -2  0  2; -1  0  1]; % 0°
            K(:,:,3) = [-1 -2 -1;  0  0  0;  1  2  1]; % 90°
            K(:,:,5) = [ 1  0 -1;  2  0 -2;  1  0 -1]; % 180°
            K(:,:,7) = [ 1  2  1;  0  0  0; -1 -2 -1]; % 270°
            K(:,:,2) = [-1 -1  0; -1  0  1;  0  1  1]; % 45°
            K(:,:,4) = [ 0  1  1; -1  0  1; -1 -1  0]; % 135°
            K(:,:,6) = [ 1  1  0;  1  0 -1;  0 -1 -1]; % 225°
            K(:,:,8) = [-1  0  1; -1  0  1;  0 -1  1]; % 315°
        otherwise
            error('family phải là prewitt|kirsch|robinson');
    end
end

function N = my_mat2gray(M)
% Chuẩn hoá min-max → [0,1] (thay cho mat2gray).
    M = double(M);
    mn = min(M(:)); mx = max(M(:));
    if mx>mn, N = (M - mn)/(mx - mn); else, N = zeros(size(M)); end
end

function U = to_uint8(M)
% Đưa ảnh về uint8 để lưu.
    N = my_mat2gray(M);
    U = uint8(round(255*N));
end