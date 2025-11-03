function morphologicalOperationsDemo(imagePath, k)
    % --- 1. Đọc ảnh ---
    I = imread(imagePath);
    if size(I,3) == 3
        I = rgb2gray(I);
    end
    if islogical(I)
    else
        I = imbinarize(I);
    end

    % --- 2. Cấu trúc phần tử (Structuring Element) ---
    SE = ones(k,k); % Mặt nạ kxk

    % --- 3. Phép co & giãn ---
    E = myErode(I, SE);
    D = myDilate(I, SE);

    % --- 4. Phép mở & đóng ---
    Opened = myDilate(myErode(I, SE), SE);  % Opening = Erosion → Dilation
    Closed = myErode(myDilate(I, SE), SE);  % Closing = Dilation → Erosion

    % --- 5. Hiển thị kết quả ---
    figure;
    subplot(2,3,1); imshow(I); title('Binarize Image');
    subplot(2,3,2); imshow(E); title('Erosion');
    subplot(2,3,3); imshow(D); title('Dilation');
    subplot(2,3,5); imshow(Opened); title('Opening');
    subplot(2,3,6); imshow(Closed); title('Closing');
end

%% Test
Iin = imgetfile;
morphologicalOperationsDemo(Iin, 5);

%% Erosion
function E = myErode(BW, SE)
    [m, n] = size(BW);
    [p, q] = size(SE);
    padx = floor(p/2);
    pady = floor(q/2);
    BW_pad = padarray(BW, [padx pady], 0, 'both');
    E = zeros(size(BW));
    for i = 1:m
        for j = 1:n
            region = BW_pad(i:i+p-1, j:j+q-1);
            if all(region(SE == 1) == 1)
                E(i, j) = 1;
            end
        end
    end
end

%% Dilation
function D = myDilate(BW, SE)
    [m, n] = size(BW);
    [p, q] = size(SE);
    padx = floor(p/2);
    pady = floor(q/2);
    BW_pad = padarray(BW, [padx pady], 0, 'both');
    D = zeros(size(BW));
    for i = 1:m
        for j = 1:n
            region = BW_pad(i:i+p-1, j:j+q-1);
            if any(region(SE == 1) == 1)
                D(i, j) = 1;
            end
        end
    end
end