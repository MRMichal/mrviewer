function mrplot_dcmData(mr)

subplot(1,1,1)
imshow(mr.dcmData(:,:,:,mr.cTime),[])
title([num2str(mr.cTime),'/',num2str(size(mr.dcmData,4))])

end