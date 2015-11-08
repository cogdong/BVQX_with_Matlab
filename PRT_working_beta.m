%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRT_working
% producing PRT file through excel file(e.g., sot.xlsx)
% beta version
% -ydy 2015.11.3-
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; clc
% bsaic information
nrofrun=2;
ExperimentName='FFA_LOC';
timeunit=2; %2=sec
sdmname = 'model01'; % should be equal to prt name



bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');
bvqx.ShowLogTab;
bvqx.PrintToLog('Creating a BrainVoyager stimulation protocol from Matlab...');
[FileName,PathName] = uigetfile('*.vmr', 'Please select the anatomical file ');
doc = bvqx.OpenDocument([PathName FileName]);
% [FileName,PathName] = uigetfile('*.vtc', 'Please select the functional file ');
% doc.LinkVTC([PathName FileName]);
[filename2,pathname2] = uigetfile('*.xlsx','Select events time file');
output = uigetdir(pathname2);

for j=1:nrofrun%run
    [nmtime,condition,raw] = xlsread([pathname2,filename2],num2str(j));
    doc.ClearStimulationProtocol();
    doc.StimulationProtocolExperimentName = ExperimentName;
    doc.StimulationProtocolResolution = timeunit;%2=sec
    k=1:2:length(condition);%condition
    for k=1:2:length(condition)%condition
        
        doc.AddCondition(condition{k});
        for l=1:size(nmtime,1)
            if isnan(nmtime(l,k))
                break
            end
            doc.AddInterval(condition{k}, nmtime(l,k), nmtime(l,k+1));
        end
        if k==1
            doc.SetConditionColor(condition{k}, 100, 100, 100);
        else
            if mod((k-1)/2,3)==1
                doc.SetConditionColor(condition{k}, 255, ((k-3)/6)*10, ((k-3)/6)*10);
            elseif mod((k-1)/2,3)==2
                doc.SetConditionColor(condition{k}, ((k-5)/6)*10, 255, ((k-5)/6)*10);
            elseif mod((k-1)/2,3)==0
                doc.SetConditionColor(condition{k}, ((k-7)/6)*10, ((k-7)/6)*10, 255);
            end
            
            doc.StimulationProtocolBackgroundColorR = 0;
            doc.StimulationProtocolBackgroundColorG = 0;
            doc.StimulationProtocolBackgroundColorB = 0;
            doc.StimulationProtocolTimeCourseColorR = 255;
            doc.StimulationProtocolTimeCourseColorG = 255;
            doc.StimulationProtocolTimeCourseColorB = 255;
            doc.StimulationProtocolTimeCourseThickness = 4;
            doc.SaveStimulationProtocol([output '\' sdmname '_run_' num2str(j) '.prt']);
        end
    end%condition
end%run
fprintf(1,'Done\n' );
