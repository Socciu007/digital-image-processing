I = imread('color\t5.tif');
I = im2double(I);
I = im2gray(I);

%% 1. Log Transformation
Rmax = max(I(:));
c = 1 / log(1 + Rmax);
log_transform = 1 * log(1 + I);
log_transform = mat2gray(log_transform); % Chuẩn hóa về [0,1]

%% 2. Gamma Transformation
gamma1 = 0.6;   % lam sang voi gamma < 1
gamma2 = 2.5;   % lam toi voi gamma > 1
power_gamma1 = I.^gamma1;
power_gamma2 = I.^gamma2;

%% 3. Piecewise Linear Transformation
r1 = 0.4; r2 = 0.8; % select range[] on image original 
s1 = 0.0; s2 = 1.0; % mapping to the entire range [0,1]

J = zeros(size(I));
for x = 1:size(I,1)
    for y = 1:size(I,2)
        r = I(x,y);
        if r < r1
            J(x,y) = s1;
        elseif r <= r2
            J(x,y) = ( (s2-s1)/(r2-r1) )*(r-r1) + s1;
        else
            J(x,y) = s2;
        end
    end
end

% Thực hiện phép biến đổi tuyến tính trơn từng khúc
% r = [0  85  170  255];   
% s = [0  51  240  255];
% for k = 1:length(r)-1
%     idx = find(I >= r(k) & I <= r(k+1));
%     J(idx) = s(k) + (s(k+1)-s(k))*(I(idx)-r(k))/(r(k+1)-r(k));
% end
% Convert uint8 image to show
% J = uint8(J);

%% Result
figure;
subplot(2,3,1), imshow(I), title('t5 Original');
subplot(2,3,2), imshow(log_transform), title('Log');
subplot(2,3,3), imshow(power_gamma1), title('Power-law (\gamma=0.6)');
subplot(2,3,4), imshow(power_gamma2), title('Power-law (\gamma=2.5)');
subplot(2,3,5), imshow(J), title('Piecewise Linear [0.4, 0.8] [0 1]');