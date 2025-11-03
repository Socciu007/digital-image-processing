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

%% Test
Iin = imgetfile;
I = imread(Iin);
if size(I,3) == 3
    I = rgb2gray(I);
end
BW = I;
% Nếu là ảnh xám thì chuyển sang nhị phân
if islogical(I)
    BW = I;
else
    BW = imbinarize(I);
end
SE = ones(3,3);

E = myErode(BW, SE);
D = myDilate(BW, SE);

figure;
subplot(1,3,1); imshow(BW); title('Binarize Image');
subplot(1,3,2); imshow(E); title('Erosion');
subplot(1,3,3); imshow(D); title('Dilation');


