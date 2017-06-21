function sensorImageRGB = FixImageArtifactsExp1P1(sensorImageRGB, filterSize)

for i = 1:3
    newImage(:,:,i) = medfilt1(sensorImageRGB(:,:,i),filterSize);
end

whichIndicesX = {[364:372]};
whichIndicesY = {[716:722]};
        

%figure; imshow(sensorImageRGB)
check = 0;
if check
    figure; imshow(sensorImageRGB);
    for k = 1:length(whichIndicesX)
        for indI = 1:length(whichIndicesX{k})
            for indJ =  1:length(whichIndicesY{k})
                sensorImageRGB(whichIndicesX{k}(indI), whichIndicesY{k}(indJ), :) = zeros*newImage(whichIndicesX{k}(indI), whichIndicesY{k}(indJ), :);
           end
        end
    end
    figure; imshow(sensorImageRGB)
end

for k = 1:length(whichIndicesX)
    for indI = 1:length(whichIndicesX{k})
        for indJ =  1:length(whichIndicesY{k})
            sensorImageRGB(whichIndicesX{k}(indI), whichIndicesY{k}(indJ), :) = newImage(whichIndicesX{k}(indI), whichIndicesY{k}(indJ), :);
        end
    end
end
figure; imshow(sensorImageRGB); 


end