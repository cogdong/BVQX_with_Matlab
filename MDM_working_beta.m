%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MDM_working
% producing MDM file across subjects for group GLM
% WARNING: all sdm files must are the same file name in each run
% across subjects.
% -ydy 2015.9.8-
% new feature: selecting subject list excel files to produce mdm.
% -ydy 2015.9.14-
% beta version
% -ydy 2015.11.3-
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear all; clc
vmrtmpl = 'E:\sample\group_result\colin_brain_aTAL.vmr';    % select one template file
parent_dir = 'E:\sample';
group_dir = 'E:\sample\group_result';
sdmname = 'model01'; % should be equal to prt name
fmr_dir = 'bvqx';


[filename2,pathname2] = uigetfile('*.xlsx','Select Subject name file');
[~,~,subject] = xlsread([pathname2,filename2]);
if ischar(subject)
    subject=cellstr(subject);
end
% subjstruct=dir(rawdir);
% subject={subjstruct.name}; subject(1:2)=[];
if ~exist(group_dir, 'dir')
        mkdir(group_dir);
end

bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');
bvqx.ShowLogTab;
bvqx.PrintToLog('Creating MDM files from Matlab...');
doc = bvqx.OpenDocument(vmrtmpl);
doc.ClearMultiStudyGLMDefinition;
for i=1:length(subject)
    PathName = ([parent_dir, '\', subject{i,1}, '\', fmr_dir, '\']);
    vtcstruct = dir([PathName subject{i} '_*_talairach.vtc']); % assumes all files are in same folder
    nrvtc = length(vtcstruct);
    for j = 1:nrvtc
        doc.AddStudyAndDesignMatrix([PathName vtcstruct(j).name],[PathName sdmname '_run_' num2str(j) '.sdm']);

    end
    bvqx.PrintToLog([num2str(i) ' Subject ', subject{i}, ' Done.']);
end%subject

doc.SaveMultiStudyGLMDefinitionFile([group_dir '\group_' sdmname '.mdm']);
bvqx.PrintToLog('MDM file finished!');
% doc.LoadMultiStudyGLMDefinitionFile([PathName 'MultiStudy_fromBVQXMatlabScript.mdm'])
% doc.ComputeMultiStudyGLM
fprintf(1,'Done\n' );