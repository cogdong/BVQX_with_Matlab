%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SDM_working
% producing SDM file for all subjects or single one automatically
% and creating single subject's mdm file and glm
% beta version
% -ydy 2015.10.13-
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; clc
parent_dir = 'E:\sample';
sdmname = 'model01'; % should be equal to prt name
fmr_dir = 'bvqx';
mdm=1;  % if mdm=1, mdm and glm will be made
nuisance=1; % if nuisance=1, motion regressors will be included in glm
nrofvols = 156;% nr of TR
subject = {
    'subj01'
    };
% set your regressors/predictors(not including 'Constant')
% corresponding to prt
regressors={
    'face'
    'object'
    'scra_object'
    };
fmr_file={
    'loc1'
    'loc2'
    };
nuisance_reg={
    'Translation BV-X'
    'Translation BV-Y'
    'Translation BV-Z'
    'Rotation BV-X'
    'Rotation BV-Y'
    'Rotation BV-Z'
    };
subjstruct=dir(parent_dir);
% [filename2,pathname2] = uigetfile('*.xlsx','Select Subject name file');
% [~,~,subject] = xlsread([pathname2,filename2]);

% subject={subjstruct.name}; subject(1:2)=[];
bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');
for i=1:length(subject)
    PathName = ([parent_dir, '\', subject{i,1}, '\', fmr_dir, '\']);
    vtcstruct = dir([PathName '*_talairach.vtc']); % assumes all files are in the same folder
    nrvtc = length(vtcstruct);
%     f=dir(fullfile(subjdir, fmr_dir));
    f=dir(PathName);
    vmrf = regexpi({f.name},['^' subject{i,1} '.*TAL.vmr'],'match'); vmrf=[vmrf{:}]; vmrf=vmrf{1};
    vmrfilename = fullfile(PathName,vmrf);
    doc = bvqx.OpenDocument(vmrfilename);
    for j = 1:nrvtc
%         doc.LinkVTC([PathName 'Vote_' num2str(j) '_SCLAI_3DMCT_talairach.vtc'])
        doc.LinkVTC([PathName vtcstruct(j).name])
        doc.LinkStimulationProtocol([PathName sdmname '_run_' num2str(j) '.prt'])
        doc.ClearDesignMatrix
        for k=1:length(regressors)
            doc.AddPredictor(regressors{k})
            doc.SetPredictorValuesFromCondition(regressors{k}, regressors{k}, 1.0)
            doc.ApplyHemodynamicResponseFunctionToPredictor(regressors{k})
        end
        if nuisance
            [y(:,1), y(:,2), y(:,3), y(:,4), y(:,5), y(:,6)]=textread([fullfile(parent_dir, subject{i,1}, fmr_dir)...
                '\' subject{i,1}, '_', fmr_file{j} '_SCLAI_3DMC.sdm'],'%f%f%f%f%f%f','headerlines',9);
            for kk=1:6
                doc.AddPredictor(nuisance_reg{kk})
                for  kkk=1:nrofvols
                    doc.SetPredictorValues(nuisance_reg{kk}, kkk, kkk, y(kkk,kk));
                end
            end
        end
        doc.AddPredictor('Constant')
        for l =1:nrofvols
            doc.SetPredictorValues( 'Constant', l, l, 1);
        end
        doc.SaveSingleStudyGLMDesignMatrix([PathName 'tmp.sdm'])
        doc.SDMContainsConstantPredictor = 1;
        doc.FirstConfoundPredictorOfSDM = k+1;
        doc.SaveSingleStudyGLMDesignMatrix([PathName sdmname '_run_' num2str(j) '.sdm'])
    end%run
    if mdm
        doc.ClearMultiStudyGLMDefinition;
        for jj = 1:nrvtc
            doc.AddStudyAndDesignMatrix([PathName vtcstruct(jj).name],[PathName sdmname '_run_' num2str(jj) '.sdm']);
        end
        doc.SaveMultiStudyGLMDefinitionFile([sdmname '.mdm']);
        doc.LoadMultiStudyGLMDefinitionFile([sdmname '.mdm']);
        doc.ComputeMultiStudyGLM;
        doc.SaveGLM([sdmname '.glm']);
    end
    bvqx.PrintToLog([num2str(i) ' Subject ', subject{i,1}, ' Done.']);
    doc.Close
end%subject
fprintf(1,'Done\n' );