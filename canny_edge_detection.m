function I_edge = MyCanny(I, sigma, T_low, T_high)
    %% ====== Pre data ======
    if size(I,3) == 3
        I = rgb2gray(I);
    end
    I = double(I);

    %% ====== Gaussian smoothing ======
    hsize = 2*ceil(3*sigma)+1;
    G = fspecial('gaussian', hsize, sigma);
    I_smooth = conv2(I, G, 'same');

    figure;
    subplot(2,3,1); imshow(uint8(I)); title('Original Image');
    % subplot(2,3,2); imshow(uint8(I_smooth)); title('Image After Gaussian smoothing');

    %% ====== Calculation gradient ======
    Gx = [-1 0 1; -2 0 2; -1 0 1];
    Gy = [1 2 1; 0 0 0; -1 -2 -1];

    Ix = conv2(I_smooth, Gx, 'same');
    Iy = conv2(I_smooth, Gy, 'same');

    Mag = sqrt(Ix.^2 + Iy.^2);
    Theta = atan2(Iy, Ix);

    subplot(2,3,2); imshow(uint8(Mag)); title('Gradient magnitude');

    %% ====== Non-maximum suppression ======
    [m, n] = size(Mag);
    NMS = zeros(m, n);
    angle = Theta * 180 / pi;
    angle(angle < 0) = angle(angle < 0) + 180;

    for i = 2:m-1
        for j = 2:n-1
            q = 255; r = 255;

            if ((angle(i,j) >= 0 && angle(i,j) < 22.5) || (angle(i,j) >= 157.5 && angle(i,j) <= 180))
                q = Mag(i, j+1);
                r = Mag(i, j-1);
            elseif (angle(i,j) >= 22.5 && angle(i,j) < 67.5)
                q = Mag(i+1, j-1);
                r = Mag(i-1, j+1);
            elseif (angle(i,j) >= 67.5 && angle(i,j) < 112.5)
                q = Mag(i+1, j);
                r = Mag(i-1, j);
            elseif (angle(i,j) >= 112.5 && angle(i,j) < 157.5)
                q = Mag(i-1, j-1);
                r = Mag(i+1, j+1);
            end

            if (Mag(i,j) >= q && Mag(i,j) >= r)
                NMS(i,j) = Mag(i,j);
            else
                NMS(i,j) = 0;
            end
        end
    end

    subplot(2,3,3); imshow(uint8(NMS)); title('Non-Maximum Suppression');

    %% ====== DOUBLE THRESHOLD ======
    strong = 255;
    weak = 50;
    I_edge = zeros(m,n);

    strong_i = NMS >= T_high;
    weak_i = (NMS >= T_low) & (NMS < T_high);

    I_edge(strong_i) = strong;
    I_edge(weak_i) = weak;

    subplot(2,3,4); imshow(uint8(I_edge)); title('Double Threshold');

    %% ====== HYSTERESIS ======
    for i = 2:m-1
        for j = 2:n-1
            if I_edge(i,j) == weak
                if any(any(I_edge(i-1:i+1, j-1:j+1) == strong))
                    I_edge(i,j) = strong;
                else
                    I_edge(i,j) = 0;
                end
            end
        end
    end

    subplot(2,3,5);
    imshow(uint8(I_edge));
    title(['Edge Canny (\sigma = ', num2str(sigma), ...
       ', T_{low} = ', num2str(T_low/255), ...
       ', T_{high} = ', num2str(T_high/255), ')'])

    I_edge = uint8(I_edge);
end

%% Test
Iin = imgetfile;
I = imread(Iin);
I_edges = MyCanny(I, 1.5, 0.15*255, 0.3*255);
