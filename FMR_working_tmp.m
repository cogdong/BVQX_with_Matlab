%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FMR_working creating and preprocessing multiple fmr
% enter all parameters and run!
% -ydy 2015.6.22-
% Warning: if existing 2 sub-folder in the subject's main folder, only one
% sub-folder will be proessed.
% -ydy 2015.7.20-
% modified to find the true folder of each run
% -ydy 2015.7.28-
% V2 version
% added other steps which could be selected (step1~5)
% added title of subject's name to the motion figure
% -ydy 2015.9.1-
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;clc;

% parameters
filetype = 'DICOM';
nrofvols = 150;% nr of TR 
nrofvolsskip = 0;
imgx = 64;
imgy = 64;
pdimx = 3;
pdimy = 3;
tr = 2000;
nrslices=40;
sthick=3;
sgap=0;
createamr = 1;
swapbytes = 0;
bytesperpixel = 2;
% preprocess setting
checpar=1;  % check image parameters
rndcm=1;    % rename dicom files?
SCLAI=1;    % step 1: Slice time correction
triDMC=1;   % step 2: 3D motion correction
SD3DSS=0;   % step 3: Spatial Gaussian Smoothing
THPGLM=0;   % step 4: Temporal High Pass Filter
TDSS=0;     % step 5: Temporal Gaussian Smoothing

rawdir = 'F:\raw_data';   % raw image changed name dir
output = 'D:\sample';       % folder for processed images

subjstruct=dir(rawdir);
subject={subjstruct.name}; subject(1:2)=[];
rundir={
    'FFA_LOC_1'
    'FFA_LOC_2'
};
anatdir = '_SAG_FSPGR_BRAVO_ASSET_3';
fmr_dir = 'fmr';
% parentdir = 'E:\bvqx_stuff\fMRI_vote1_YBprt';% study's dir
% rundir1 = 'loc_1';
% rundir2 = 'loc_2';
% nrofprojects = size(subject)*size(rundir);    %counting nb of sessions of all subjects
% save_dir = fullfile(subject, 'D:\bvqx_data\'
 %output dir name
%fmr_name = 'facelike';  %outpute .fmr name
%outpute .fmr name
% outputfmr={
%     'run1'
%     };

% prt_names = {
%             };
% to_be_aligned_fmr_name = strcat(fullfile(parentdir, fmr_dir), '\', outputfmr{1}, '_firstvol.fmr');


% h = msgbox(['Via this script will be multiple FMRs created and preprocessed']);
% uiwait(h);
bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');
bvqx.ShowLogTab;
bvqx.PrintToLog('Creating FMR files from Matlab...');

for i=1:length(subject)
    uf=dir(fullfile(rawdir,subject{i}));uf_tmp=struct2cell(uf(3));
    subjdir=fullfile(rawdir, subject{i}, uf_tmp{1});
    cd(subjdir);
    rf=dir(subjdir);
    if rndcm%rename dicom files?
        for m=1:length(rundir)
            crundir = regexpi({rf.name},['^' rundir{m} '.*'],'match'); crundir=[crundir{:}]; %crundir=crundir{1};
%             if ~exist(fullfile(subjdir, crundir),'dir') %check folder existed
            if isempty(crundir)
                continue
            else
                    crundir=crundir{1};
            end
            bvqx.RenameDicomFilesInDirectory(fullfile(subjdir, crundir))
        end
    end
    
    mkdir(fmr_dir);
%     to_be_aligned_fmr_name = strcat(fullfile(parentdir, fmr_dir), '\', outputfmr{1},'_r',num2str(i,'%02d'), '_firstvol.fmr');
    to_be_aligned_fmr_name=strcat(fullfile(subjdir, fmr_dir), '\', 'Vote_1', '_firstvol.fmr');
    yy=[];
    for j=1:length(rundir)
        crundir = regexpi({rf.name},['^' rundir{j} '.*'],'match'); crundir=[crundir{:}]; %crundir=crundir{1};
%         if ~exist(fullfile(subjdir, crundir),'dir') %check folder existed
        if isempty(crundir)
                continue
        else
            crundir=crundir{1};
        end
        f=dir(fullfile(subjdir, crundir));
        f = regexpi({f.name},'.*00001.dcm','match'); f=[f{:}]; f=f{1};
        first_dcm_names=strcat(subjdir,'\',crundir, '\', f);
        %       [pathstr,name,ext,versn] = fileparts(fmr_names{i,1});
        %         pathstrs=fullfile(parentdir, subject{i}, fmr_dir);
%         pathstrs=fullfile(parentdir, fmr_dir);
        %         stcname=strcat(fmr_name,'_', rundir{j});
%         fmrname = strcat(pathstrs, '\', outputfmr{j},'_r',num2str(j,'%02d'), '.fmr');
%         stcname=strcat(outputfmr{j},'_r',num2str(j,'%02d'));
%         fmrname = 'D:\bvqx_stuff\meng_testing\r01.fmr';%strcat('D:\bvqx_stuff\meng_testing\','r',num2str(j,'%02d'), '.fmr');
        fmrname = strcat(fullfile(subjdir, fmr_dir), '\', rundir{j}, '.fmr');
        [pathstr,name,ext,versn] = fileparts(fmrname);
%         pathstr='D:\bvqx_stuff\meng_testing';
        stcname=name;%'r01';%strcat('r',num2str(j,'%02d'));
        fmr = bvqx.CreateProjectFMR(filetype, first_dcm_names, nrofvols,...
            nrofvolsskip, createamr, nrslices,...
            stcname,swapbytes, imgx, imgy, bytesperpixel, pathstr);
        fmr.SaveAs(fmrname);
        fmr.Close;
        
        % start preprocessing
        docFMR = bvqx.OpenDocument(fmrname);
        if ~docFMR.TimeResolutionVerified
            docFMR.TR = tr; %specific for weng lab
            docFMR.InterSliceTime = tr/nrslices;
            docFMR.TimeResolutionVerified = 1;
        end
        if ~docFMR.VoxelResolutionVerified
            docFMR.PixelSizeOfSliceDimX = pdimx;
            docFMR.PixelSizeOfSliceDimY = pdimy;
            docFMR.SliceThickness = sthick;
            docFMR.GapThickness = sgap;
            docFMR.VoxelResolutionVerified = 1;
        end
        bvqx.PrintToLog('Preprocessing FMR files from Matlab...');
        % link the prt file (not link here)
%         docFMR.LinkStimulationProtocol(strcat(fullfile(parentdir), '\', prt_names{j,1}));
        % We save the new settings into the FMR file
        docFMR.Save;
        if SCLAI
        % Preprocessing step 1: Slice time correction
        bvqx.PrintToLog('step 1: Slice time correction');
        docFMR.CorrectSliceTiming( 1, 0 );
        % First param: Scan order 0 -> Ascending, 1 -> Asc-Interleaved, 2 -> Asc-Int2,
        % 10 -> Descending, 11 -> Desc-Int, 12 -> Desc-Int2
        % Second param: Interpolation method: 0 -> trilinear, 1 -> cubic spline, 2 -> sinc
        ResultFileName = docFMR.FileNameOfPreprocessdFMR;
        docFMR.Close;
        end
        if triDMC
        docFMR = bvqx.OpenDocument( ResultFileName );
        % Preprocessing step 2: 3D motion correction
        bvqx.PrintToLog('step 2: 3D motion correction');
        docFMR.CorrectMotionTargetVolumeInOtherRun(to_be_aligned_fmr_name, 1);
        % the current doc (input FMR) knows the name of the automatically saved output FMR
        ResultFileName = docFMR.FileNameOfPreprocessdFMR;
        %docFMR.Remove; % close or remove input FMR
        %bvqx.PrintToLog('Removed slice scan time corrected files instead of just closing...');
        docFMR.Close(); % close input FMR
        % Open motion corrected file (output FMR) and assign to our doc var
        end
        if SD3DSS
        docFMR = bvqx.OpenDocument( ResultFileName );
        % Preprocessing step 3: Spatial Gaussian Smoothing (not recommended
        % for individual analysis with a 64x64 matrix)
        bvqx.PrintToLog('step 3: Spatial Gaussian Smoothing');
        docFMR.SpatialGaussianSmoothing( 4, 'mm'); % FWHM value and unit
        ResultFileName = docFMR.FileNameOfPreprocessdFMR;
        docFMR.Close; % docFMR.Remove(); % close or remove input FMR
        end
        if THPGLM
        docFMR = bvqx.OpenDocument( ResultFileName );
        % Preprocessing step 4: Temporal High Pass Filter, includes Linear Trend
        % Removal
        bvqx.PrintToLog('step 4: Temporal High Pass Filter');
        docFMR.TemporalHighPassFilter( 2, 'cycles');
        ResultFileName = docFMR.FileNameOfPreprocessdFMR;
        docFMR.Close(); % close or remove input FMR
        %bvqx.PrintToLog('Removed motion corrected intermitten files ...');
        end
        if TDSS
        docFMR = bvqx.OpenDocument( ResultFileName );
        % Preprocessing step 5: Temporal Gaussian Smoothing (not recommended for
        % event-related data)
        bvqx.PrintToLog('step 5: Temporal Gaussian Smoothing');
        docFMR.TemporalGaussianSmoothing( 10, 's');
        ResultFileName = docFMR.FileNameOfPreprocessdFMR;
        docFMR.Close; % docFMR.Remove(); % close or remove input FMR
        end     
        
        %bvqx.PrintToLog('Removed slice scan time corrected files instead of just closing...');
        %load motion sdm file
        [y(:,1), y(:,2), y(:,3), y(:,4), y(:,5), y(:,6)]=textread([fullfile(subjdir, fmr_dir) '\' rundir{j} '_SCLAI_3DMC.sdm'],'%f%f%f%f%f%f','headerlines',9);
        yy=[yy;y];
    end%rundir
    x=[1:length(yy)];
    figure
    plot(x,yy(:,1),x,yy(:,2),x,yy(:,3),x,yy(:,4),x,yy(:,5),x,yy(:,6))
    legend('x-t(mm)','y-t(mm)','z-t(mm)','x-r(degs)','y-r(degs)','z-r(degs)','location','Best')
    xlabel('TR');ylabel('Intensity')
    title(subject{i});
    print('-dpng',[fullfile(subjdir, fmr_dir) '\' 'realign.png'])
    close
end%subject