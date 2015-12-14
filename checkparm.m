% V1.1
% add TE info
% -ydy 2015.12.14-

function checkparm
clc
[filename2,pathname2] = uigetfile('*.dcm','Select One DCM');
imginfo = dicominfo([pathname2,filename2]);
% print the parameters
fprintf(1, 'number of slices(nrslices) = %s\n', num2str(imginfo.ImagesInAcquisition));
if isfield(imginfo, 'NumberOfTemporalPositions')
    fprintf(1, 'number of TRs(nrofvols) = %s\n', num2str(imginfo.NumberOfTemporalPositions));
end
fprintf(1, 'TR(ms) = %s\n', num2str(imginfo.RepetitionTime));
fprintf(1, 'TE(ms) = %s\n', num2str(imginfo.EchoTime));
fprintf(1, 'X resolution(imgx) = %s\n', num2str(imginfo.Width));
fprintf(1, 'Y resolution(imgy) = %s\n', num2str(imginfo.Height));
fprintf(1, 'pdimx = %s\n', num2str(imginfo.ReconstructionDiameter/imginfo.Width));
fprintf(1, 'pdimy = %s\n', num2str(imginfo.ReconstructionDiameter/imginfo.Height));
fprintf(1, 'Slice Thickness(sthick) = %s\n', num2str(imginfo.SliceThickness));
fprintf(1, 'Slice Gap(sgap) = %s\n', num2str(imginfo.SpacingBetweenSlices-imginfo.SliceThickness));
end

