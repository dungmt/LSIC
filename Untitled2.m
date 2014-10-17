Im1 = imread('D:\download3.jpg');
Im2 = imread('D:\download2.jpg');
subplot(2,2,1), imshow(Im1);title('hinh 1')
subplot(2,2,2), imshow(Im2);title('hinh 2')

Im1 = rgb2gray(Im1);
Im2 = rgb2gray(Im2);

subplot(2,2,3),imhist(Im1); title('bieu do 1');
subplot(2,2,4),imhist(Im2); title('bieu do 2');
hn1 = imhist(Im1)./numel(Im1);
hn2 = imhist(Im2)./numel(Im2);

d = sum(abs(cumsum(hn1) - cumsum(hn2)));
if d >= 50
disp('2 hinh tren giong nhau')
else 
disp('2 hinh tren khong giong nhau') 
end; 

