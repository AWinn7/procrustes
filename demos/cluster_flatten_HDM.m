%cluster_flatten_HDM

%%% preparation
clear vars;
close all;
path(pathdef);

wd = '/home/ugrad/acw23/projects/tac/procrustes/demos';
addpath(path,genpath([wd '/../utils/']));

%%% setup paths
base_path = [wd '/'];
%disp(base_path);
data_path = [base_path '../../data/'];
meshes_path = [data_path 'samples/subsample/nakwai_50_subsample_offs/ss_mesh_2_offs/'];
samples_path = [data_path 'results/subsample_cF_HDM_results/'];
cluster_path = [base_path 'cluster/'];
scripts_path = [cluster_path 'scripts/'];
errors_path = [cluster_path 'errors/'];
outputs_path = [cluster_path 'outputs/'];

disp(base_path);
disp(scripts_path);

%%% build folders if they don't exist
%touch(samples_path);
%touch(scripts_path);
%touch(errors_path);
%touch(outputs_path);

%%% clean up paths
command_text = ['!rm -f ' scripts_path '*']; eval(command_text); disp(command_text);
command_text = ['!rm -f ' errors_path '*']; eval(command_text); disp(command_text);
command_text = ['!rm -f ' outputs_path '*']; eval(command_text); disp(command_text);
command_text = ['!rm -f ' samples_path '*']; eval(command_text); disp(command_text);

%%% load taxa codes
taxaFile=[data_path 'workspaces/HDM_Workspace.mat'];
load(taxaFile, 'taxa_code');
GroupSize = length(taxa_code);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('++++++++++++++++++++++++++++++++++++++++++++++++++');
disp(['Submitting jobs for sampling mesh files in' meshes_path '...' ]);

for k = 1:GroupSize
    job_id = k;
    
    if (exist([samples_path taxa_code{k} '.mat'], 'file'))
        job_id = job_id+1;
        continue;
    end
    
    script_name = [scripts_path 'script_' num2str(job_id)];
    
    mesh_file= [meshes_path taxa_code{k} '.off'];
    sample_file= [samples_path taxa_code{k} '.mat'];
    
    fid = fopen(script_name,'w');
    fprintf(fid, '#!/bin/bash\n');
    fprintf(fid, '#$ -S /bin/bash\n');
    script_text = ['matlab -nodesktop -nodisplay -nojvm -nosplash -r ' ...
        ' "cd ' base_path '; ' ...
        'path(genpath(''' base_path '../utils/''), path); ' ...
        'flatten_ongrid ' ...
        mesh_file ' ' ...
        sample_file '; exit; "'];
    % system(script_text); %% grid fails on certain tasks
    fprintf(fid, '%s',script_text);
    fclose(fid);
   
    system(['chmod u+x ' script_name]); 
    %%% qsub
    jobname = ['TCjob_' num2str(job_id)];
    serr = [errors_path 'e_job_' num2str(job_id)];
    sout = [outputs_path 'o_job_' num2str(job_id)];
    system(script_name);
    %tosub = ['!qsub -N ' jobname ' -o ' sout ' -e ' serr ' ' script_name ];
    %tosub = ['!myqsub3 ' script_name];
    %disp(tosub);
    %eval(tosub);
    
end
