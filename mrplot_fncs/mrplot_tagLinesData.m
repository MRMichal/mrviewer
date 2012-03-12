function mrplot_tagLinesData(mr)

subplot(1,3,1)
imshow(mr.tagLinesHarp1(:,:,:,mr.cTime),[])
subplot(1,3,2)
imshow(mr.tagLinesHarp2(:,:,:,mr.cTime),[])
subplot(1,3,3)
imshow(mr.tagPointsHarp(:,:,:,mr.cTime),[])

end