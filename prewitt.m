function I_outs = MyPrewitt(I, T)
    % --- Bước 1: Đọc ảnh & chuyển sang xám ---
    if size(I,3) == 3
        I_gray = rgb2gray(I);
    else
        I_gray = I;
    end
    I_gray = double(I_gray);

    figure; 
    subplot(2,3,1); imshow(uint8(I_gray)); title('Original image');

    % --- Bước 2: Tạo mặt nạ Prewitt ---
    Gx = [-1 0 1; -1 0 1; -1 0 1];
    Gy = [-1 -1 -1; 0 0 0; 1 1 1];

    % --- Bước 3: Pad biên ảnh ---
    [m,n] = size(I_gray);
    I_pad = padarray(I_gray,[1 1],'replicate');
    Ix = zeros(m,n);
    Iy = zeros(m,n);

    % --- Bước 4: Tính gradient theo X và Y ---
    for i = 2:m+1
        for j = 2:n+1
            % Trích vùng 3x3
            mask = I_pad(i-1:i+1, j-1:j+1);
            % Tính tích chập
            Ix(i-1,j-1) = sum(sum(mask .* Gx));
            Iy(i-1,j-1) = sum(sum(mask .* Gy));
        end
    end

    subplot(2,3,2); imshow(uint8(abs(Ix))); title('Gradient by X');
    subplot(2,3,3); imshow(uint8(abs(Iy))); title('Gradient by Y');

    % --- Bước 5: Độ lớn biên ---
    G = sqrt(Ix.^2 + Iy.^2);
    G = G / max(G(:)) * 255;

    subplot(2,3,4); imshow(uint8(G)); title('Gradient magnitude');

    % --- Bước 6: Ngưỡng phát hiện biên ---
    edge_img = G > T;
    subplot(2,3,5); imshow(edge_img); title(['Edge Prewitt, T = ', num2str(T)]);

    % --- Bước 7: So sánh với biên MATLAB (để tham khảo) ---
    % E = edge(uint8(I_gray), 'prewitt');
    % subplot(2,3,6); imshow(E); title('Biên (MATLAB Prewitt)');
end

Iin = imgetfile;
I = imread(Iin);
I_outs = MyPrewitt(I, 110);