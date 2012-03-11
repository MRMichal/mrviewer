function mrplot_mrData(mr)

subplot(1,1,1)
imshow(mr.mrData(:,:,:,mr.cTime),[])
title([num2str(mr.cTime),'/',num2str(size(mr.mrData,4))])

end