function [] = preproc_metabatch_example()

% This function is an example of how to set up a batch script for running
% SPM8 routines across multiple subjects. It loops across subjects, 
% defining subject-specific variables (according to default variables + 
% subject-specific exceptions). These variables are then substituted into a
% subfunction containing the output from the SPM8 batch editor. In this 
% way, the script is very flexible- any routine from the SPM8 batch system 
% can be generalized to fit into this framework. The below batch_job
% subfunction is a basic fMRI pre-processing routine.
%
% Author: Maureen Ritchey, updated 03/2013

%
% Logan edited this 20180628
% Just have to edit the top variables and directores
%
% and then put in your batch SPM code at the end of the script
% good luck. My email is logan.dowdle@gmail.com 

clear all;
curdir = pwd;

%Specify variables
outLabel = 'batch_pp'; %output label that the batch file will be named
subjects = {'1018' 'sub002' 'sub004' 'sub005' };%put subjects here, in single quotes divided by spaces
%The spaces are important
dataDir = '/data/cairhive0/studies_large/hanlon_share/study_name/data_folder';
runs = {'motor_tesk_1' 'motor_task_2'}; %this is the name of the run folder
%It can be just one thing. Depending on the batch code, this may not be needed. 
%if it is not delete the runs sections on line 38. 
anatDir = 'anat';

for i=1:length(subjects)
    %Define variables for individual subjects
    b.curSubj = subjects{i};
    b.dataDir = strcat(dataDir,b.curSubj,'/','convert/')
    b.runs = runs;
    b.anatDir = anatDir;
    
    %Run exceptions for subject-specific naming conventions
    b = run_exceptions(b);
    
    %specify matlabbatch variable with subject-specific inputs
    matlabbatch = batch_job(b);
    
    %save matlabbatch variable for posterity
    outName = strcat(b.dataDir,outLabel,'_',date); %This adds the date to the batch name. 
    save(outName, 'matlabbatch');
    
    %run matlabbatch job
    cd(b.dataDir);
    try
        spm_jobman('initcfg')
        spm('defaults', 'FMRI');
        spm_jobman('serial', matlabbatch);
    catch
        cd(curdir);
        continue;
    end
    cd(curdir);
    
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [b] = run_exceptions(b)

if strcmp(b.curSubj,'s02')
    b.runs = {'epi_0002' 'epi_0003'};
end

end


function [matlabbatch]=batch_job(b)
%This function generates the matlabbatch variable: can be copied in
%directly from the batch job output, then modify lines as necessary to
%generalize the paths, etc, using b variables

%This is where you batch goes. Note line 90 - that just points at the subject anat fodler in this case.
% It could also point at the top level subject folder just as easily. 

%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------
matlabbatch{1}.cfg_basicio.file_dir.dir_ops.cfg_named_dir.name = 'Subject Anat Folder';
matlabbatch{1}.cfg_basicio.file_dir.dir_ops.cfg_named_dir.dirs = {[b.dataDir b.anatDir '/']};
matlabbatch{2}.cfg_basicio.file_dir.dir_ops.cfg_named_dir.name = 'Motor Task 1 and 2 -';
matlabbatch{2}.cfg_basicio.file_dir.dir_ops.cfg_named_dir.dirs = {
                                                                  {[b.dataDir b.runs{1} '/']}
                                                                  {[b.dataDir b.runs{1} '/']}
                                                                  }';
matlabbatch{3}.cfg_basicio.file_dir.file_ops.file_fplist.dir(1) = cfg_dep('Named Directory Selector: Subject Anat Folder(1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','dirs', '{}',{1}));
matlabbatch{3}.cfg_basicio.file_dir.file_ops.file_fplist.filter = '^brain_.*nii';
matlabbatch{3}.cfg_basicio.file_dir.file_ops.file_fplist.rec = 'FPList';
matlabbatch{4}.cfg_basicio.file_dir.file_ops.file_fplist.dir(1) = cfg_dep('Named Directory Selector: Subject Anat Folder(1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','dirs', '{}',{1}));
matlabbatch{4}.cfg_basicio.file_dir.file_ops.file_fplist.filter = '^y_M.*nii';
matlabbatch{4}.cfg_basicio.file_dir.file_ops.file_fplist.rec = 'FPList';
matlabbatch{5}.cfg_basicio.file_dir.file_ops.file_fplist.dir(1) = cfg_dep('Named Directory Selector: Motor Task 1 and 2 -(1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','dirs', '{}',{1}));
matlabbatch{5}.cfg_basicio.file_dir.file_ops.file_fplist.filter = '^fM.*nii';
matlabbatch{5}.cfg_basicio.file_dir.file_ops.file_fplist.rec = 'FPList';
matlabbatch{6}.cfg_basicio.file_dir.file_ops.file_fplist.dir(1) = cfg_dep('Named Directory Selector: Motor Task 1 and 2 -(2)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','dirs', '{}',{2}));
matlabbatch{6}.cfg_basicio.file_dir.file_ops.file_fplist.filter = '^fM.*nii';
matlabbatch{6}.cfg_basicio.file_dir.file_ops.file_fplist.rec = 'FPList';
matlabbatch{7}.spm.util.exp_frames.files(1) = cfg_dep('File Selector (Batch Mode): Selected Files (^fM.*nii)', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{7}.spm.util.exp_frames.frames = Inf;
matlabbatch{8}.spm.util.exp_frames.files(1) = cfg_dep('File Selector (Batch Mode): Selected Files (^fM.*nii)', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{8}.spm.util.exp_frames.frames = Inf;
matlabbatch{9}.spm.spatial.realign.estwrite.data{1}(1) = cfg_dep('Expand image frames: Expanded filename list.', substruct('.','val', '{}',{7}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{9}.spm.spatial.realign.estwrite.data{2}(1) = cfg_dep('Expand image frames: Expanded filename list.', substruct('.','val', '{}',{8}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{9}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{9}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{9}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{9}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{9}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{9}.spm.spatial.realign.estwrite.eoptions.wrap = [0 1 0];
matlabbatch{9}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{9}.spm.spatial.realign.estwrite.roptions.which = [2 1];
matlabbatch{9}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{9}.spm.spatial.realign.estwrite.roptions.wrap = [0 1 0];
matlabbatch{9}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{9}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
matlabbatch{10}.spm.spatial.coreg.estimate.ref(1) = cfg_dep('File Selector (Batch Mode): Selected Files (^brain_.*nii)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{10}.spm.spatial.coreg.estimate.source(1) = cfg_dep('Realign: Estimate & Reslice: Mean Image', substruct('.','val', '{}',{9}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));
matlabbatch{10}.spm.spatial.coreg.estimate.other(1) = cfg_dep('Realign: Estimate & Reslice: Realigned Images (Sess 1)', substruct('.','val', '{}',{9}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','cfiles'));
matlabbatch{10}.spm.spatial.coreg.estimate.other(2) = cfg_dep('Realign: Estimate & Reslice: Realigned Images (Sess 2)', substruct('.','val', '{}',{9}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{2}, '.','cfiles'));
matlabbatch{10}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{10}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{10}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{10}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
matlabbatch{11}.spm.spatial.coreg.estwrite.ref(1) = cfg_dep('File Selector (Batch Mode): Selected Files (^brain_.*nii)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{11}.spm.spatial.coreg.estwrite.source(1) = cfg_dep('Realign: Estimate & Reslice: Mean Image', substruct('.','val', '{}',{9}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));
matlabbatch{11}.spm.spatial.coreg.estwrite.other = {''};
matlabbatch{11}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{11}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{11}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{11}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{11}.spm.spatial.coreg.estwrite.roptions.interp = 4;
matlabbatch{11}.spm.spatial.coreg.estwrite.roptions.wrap = [0 1 0];
matlabbatch{11}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{11}.spm.spatial.coreg.estwrite.roptions.prefix = '_anat_align_check';
matlabbatch{12}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('File Selector (Batch Mode): Selected Files (^y_M.*nii)', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{12}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Coregister: Estimate & Reslice: Coregistered Images', substruct('.','val', '{}',{11}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
matlabbatch{12}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                           78 76 85];
matlabbatch{12}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
matlabbatch{12}.spm.spatial.normalise.write.woptions.interp = 4;
matlabbatch{13}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{12}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{13}.spm.spatial.smooth.fwhm = [8 8 8];
matlabbatch{13}.spm.spatial.smooth.dtype = 0;
matlabbatch{13}.spm.spatial.smooth.im = 0;
matlabbatch{13}.spm.spatial.smooth.prefix = 's';
matlabbatch{14}.spm.spatial.realignunwarp.data(1).scans(1) = cfg_dep('File Selector (Batch Mode): Selected Files (^fM.*nii)', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{14}.spm.spatial.realignunwarp.data(1).pmscan = '';
matlabbatch{14}.spm.spatial.realignunwarp.data(2).scans(1) = cfg_dep('File Selector (Batch Mode): Selected Files (^fM.*nii)', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{14}.spm.spatial.realignunwarp.data(2).pmscan = '';
matlabbatch{14}.spm.spatial.realignunwarp.eoptions.quality = 0.9;
matlabbatch{14}.spm.spatial.realignunwarp.eoptions.sep = 4;
matlabbatch{14}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
matlabbatch{14}.spm.spatial.realignunwarp.eoptions.rtm = 1;
matlabbatch{14}.spm.spatial.realignunwarp.eoptions.einterp = 2;
matlabbatch{14}.spm.spatial.realignunwarp.eoptions.ewrap = [0 1 0];
matlabbatch{14}.spm.spatial.realignunwarp.eoptions.weight = '';
matlabbatch{14}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
matlabbatch{14}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
matlabbatch{14}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
matlabbatch{14}.spm.spatial.realignunwarp.uweoptions.jm = 0;
matlabbatch{14}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
matlabbatch{14}.spm.spatial.realignunwarp.uweoptions.sot = [];
matlabbatch{14}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
matlabbatch{14}.spm.spatial.realignunwarp.uweoptions.rem = 1;
matlabbatch{14}.spm.spatial.realignunwarp.uweoptions.noi = 5;
matlabbatch{14}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
matlabbatch{14}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
matlabbatch{14}.spm.spatial.realignunwarp.uwroptions.rinterp = 4;
matlabbatch{14}.spm.spatial.realignunwarp.uwroptions.wrap = [0 1 0];
matlabbatch{14}.spm.spatial.realignunwarp.uwroptions.mask = 1;
matlabbatch{14}.spm.spatial.realignunwarp.uwroptions.prefix = 'u';
matlabbatch{15}.spm.spatial.coreg.estimate.ref(1) = cfg_dep('File Selector (Batch Mode): Selected Files (^brain_.*nii)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{15}.spm.spatial.coreg.estimate.source(1) = cfg_dep('Realign & Unwarp: Unwarped Mean Image', substruct('.','val', '{}',{14}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','meanuwr'));
matlabbatch{15}.spm.spatial.coreg.estimate.other(1) = cfg_dep('Realign & Unwarp: Unwarped Images (Sess 1)', substruct('.','val', '{}',{14}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','uwrfiles'));
matlabbatch{15}.spm.spatial.coreg.estimate.other(2) = cfg_dep('Realign & Unwarp: Unwarped Images (Sess 2)', substruct('.','val', '{}',{14}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{2}, '.','uwrfiles'));
matlabbatch{15}.spm.spatial.coreg.estimate.other(3) = cfg_dep('Realign & Unwarp: Unwarped Mean Image', substruct('.','val', '{}',{14}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','meanuwr'));
matlabbatch{15}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{15}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{15}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{15}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
matlabbatch{16}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('File Selector (Batch Mode): Selected Files (^y_M.*nii)', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{16}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{15}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
matlabbatch{16}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                           78 76 85];
matlabbatch{16}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
matlabbatch{16}.spm.spatial.normalise.write.woptions.interp = 4;
matlabbatch{17}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{16}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{17}.spm.spatial.smooth.fwhm = [8 8 8];
matlabbatch{17}.spm.spatial.smooth.dtype = 0;
matlabbatch{17}.spm.spatial.smooth.im = 0;
matlabbatch{17}.spm.spatial.smooth.prefix = 's';
