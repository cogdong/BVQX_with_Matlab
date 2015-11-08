%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create_multiple_vtcs.m
% Script to create volume time course files (*.vtc)
% For use: load in Matlab and press 'run'.
% VTC_working
% Works with BrainVoyager QX 2.2
% modified -ydy 2015.6.17-
% beta version
% -ydy 2015.9.30-
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; clc
parent_dir = 'E:\sample';
fmr_dir = 'bvqx';
fmr_file={
    'loc1'
    'loc2'
    };
subject = {
    'subj01'
    };
% parameters
    resolution = 3;
    space = 3; % {'native', 'acpc', 'talairach'}
    interpolation = 1; % trilinear
    bbithresh = 100;
    cerebellum = 0; %extended Talairach space
    datatype = 1; % 1: integer 16-bit; 2: float 32
    vtcspaces = {'native', 'acpc', 'talairach'};

bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');
bvqx.ShowLogTab;
bvqx.PrintToLog('Creating VTC files from Matlab...');
cd(parent_dir)
for i=1:length(subject)
    % Warning: if existing 2 sub-folder in the subject's main folder, only one
    % sub-folder will be proessed.
    %uf=dir(fullfile(rawdir,subject{i}));uf_tmp=struct2cell(uf(3));
    subjdir=fullfile(parent_dir, subject{i}, fmr_dir);
    cd(subjdir);
    % looking for last processed fmr
    allfmr=dir('*.fmr');
    allfmrc={allfmr.name}';
    [~, c]=max(cellfun(@length, allfmrc));
    parts = strread(allfmrc{c},'%s','delimiter','_');   

    fmrfile=dir(['*' parts{end}]);
    nrofprojects = length(fmrfile);
    
    %looking for the vmr file
    f=dir(pwd);
%     f=dir(fullfile(subjdir, anatdir));
    %vmrf = regexpi({f.name},'.*_ISO_IIHC_aTAL.vmr','match');
    %vmrf=[vmrf{:}]; vmrf=vmrf{1};
    vmrf = regexpi({f.name},'.*TAL.vmr','match'); vmrf=[vmrf{:}]; vmrf=vmrf{1};
    vmrfilename = fullfile(subjdir,vmrf);
    %looking for the coregietrated files
    %     fmrname = strcat(fullfile(subjdir, fmr_dir), '\', rundir{j}, '.fmr');
    fmrf=dir(pwd);
    iaf=regexpi({fmrf.name},['^' subject{i} '_' fmr_file{1} '_firstvol' '.*IIHC_IA.trf'],'match'); iaf=[iaf{:}]; iaf=iaf{1};
    ia_names{1}=fullfile(subjdir, iaf);
    faf=regexpi({fmrf.name},['^' subject{i} '_' fmr_file{1} '_firstvol' '.*IIHC_FA.trf'],'match'); faf=[faf{:}]; faf=faf{1};
    fa_names{1}=fullfile(subjdir, faf);
    %acpcf=regexpi({f.name},'.*_ISO_IIHC_aACPC.trf','match'); acpcf=[acpcf{:}]; acpcf=acpcf{1};
    acpcf=regexpi({f.name},'.*ACPC.trf','match'); acpcf=[acpcf{:}]; acpcf=acpcf{1};
    acpc_names{1}=fullfile(subjdir, acpcf);
    %talf=regexpi({f.name},'.*_ISO_IIHC_aACPC.tal','match'); talf=[talf{:}]; talf=talf{1};
    talf=regexpi({f.name},'.*ACPC.tal','match'); talf=[talf{:}]; talf=talf{1};
    tal_names{1}=fullfile(subjdir, talf);
    
    fmr_names = cell(nrofprojects, 1);
    vtc_names = cell(nrofprojects, 1);
    
    for j=1:length(fmrfile)
        fmr_names{j,1} =  strcat(subjdir, '\', fmrfile(j).name);
        [pathstr,name,ext,versn] = fileparts(fmr_names{j,1});
        vtc_names{j,1} = fullfile(pathstr, [name '_' vtcspaces{space} '.vtc']);
    end 
    vmrproject = bvqx.OpenDocument(vmrfilename);
    vmrproject.ExtendedTALSpaceForVTCCreation = cerebellum;
    
    for k=1:nrofprojects % creating VTC for each project
%         if ~exist(fullfile(subjdir, rundir{k}),'dir') %check folder existed
%             continue
%         end
        if space == 1
            success = vmrproject.CreateVTCInVMRSpace(fmr_names{k,1}, ia_names{1}, fa_names{1},...
                vtc_names{k,1}, datatype, resolution, interpolation, bbithresh);
        elseif space == 2
            success = vmrproject.CreateVTCInACPCSpace(fmr_names{k,1}, ia_names{1}, fa_names{1},...
                acpc_names{1}, vtc_names{k,1}, datatype, ...
                resolution, interpolation, bbithresh);
        elseif space == 3
            success = vmrproject.CreateVTCInTALSpace(fmr_names{k,1}, ia_names{1}, fa_names{1},...
                acpc_names{1}, tal_names{1}, vtc_names{k,1}, datatype, ...
                resolution, interpolation, bbithresh);
        else
            disp('An error occurred. Our apologies');
        end
        if (success == 1)
            bvqx.PrintToLog(['Created ' vtc_names{k,1}]);
        else
            disp(['An error occurred while creating the VTC file' vtc_names{k,1}]);
        end
    end%run
    vmrproject.Close
end%subject

% button = questdlg('Would you like to save the VTC parameters (for later use of this script)?','Create multiple VTCs');
% if strcmp(button, 'Yes') == 1
%     vtcparamsfilename = fullfile(pathstr, 'vtcparams.mat')
%     save(vtcparamsfilename);
% end
bvqx.PrintToLog('Done');
fprintf(1,'Done\n' );