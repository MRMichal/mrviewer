function mrplot_harpData(mr)

% subplot(2,2,1),imshow(mr.harP1(:,:,1,mr.cTime),[])
% subplot(2,2,2),imshow(mr.harP2(:,:,1,mr.cTime),[])
% subplot(2,2,3),imshow(mr.harM1(:,:,1,mr.cTime),[])
% subplot(2,2,4),imshow(mr.harM2(:,:,1,mr.cTime),[])

subplot(2,3,1),imshow(mr.mrData(:,:,1,mr.cTime),[])
subplot(2,3,2),imshow(mr.harP1(:,:,1,mr.cTime),[])
subplot(2,3,5),imshow(mr.harP2(:,:,1,mr.cTime),[])
subplot(2,3,3),imshow(mr.harM1(:,:,1,mr.cTime),[])
subplot(2,3,6),imshow(mr.harM2(:,:,1,mr.cTime),[])
%
subplot(2,3,4),
F=fft2(mr.mrData(:,:,1,mr.cTime));F(1,1)=0;
imshow(fftshift(abs(F)),[]);hold on
contour(mr.myFilter(:,:,1,mr.cTime),1);colormap jet;alpha(0.6);hold off

subplot(2,3,1)
title([num2str(mr.cTime),'/',num2str(size(mr.harP1,4))])
subplot(2,3,6)
end