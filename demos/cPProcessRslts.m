%%% preparation
clear all;
close all;
path(pathdef);
wd = '/home/ugrad/acw23/projects/tac/procrustes/demos';
utils_path = [wd '/../utils/'];
disp(utils_path);
addpath(path,genpath(utils_path));
addpath(path,genpath([wd '/../utils/utils_cluster/']));

%%% setup paths
base_path = [wd '/'];
data_path = [base_path '../../data/'];
% result_path = '/xtmp/ArchivedResults/Clement/cPdist/'; 
result_path = [data_path 'results/cpp_results/']; 
rslts_path = [result_path '../rslts/'];
TextureCoords1Matrix_path = [result_path 'TextureCoords1/'];
TextureCoords2Matrix_path = [result_path 'TextureCoords2/'];

%%% check if texture paths exist
command=['touch ', result_path];system(command);
%touch(result_path);
command=['touch ', TextureCoords1Matrix_path];system(command);
%touch(TextureCoords1Matrix_path);
command=['touch ', TextureCoords2Matrix_path];system(command);
%touch(TextureCoords2Matrix_path);

%%% clean up texture coordinates matrices
%command_text = ['!rm -f ' TextureCoords1Matrix_path '*'];
%system(command_text); disp(command_text);
%command_text = ['!rm -f ' TextureCoords2Matrix_path '*'];
%system(command_text); disp(command_text);

%%% load taxa codes
taxaFile=[data_path 'workspaces/HDM_Workspace.mat'];
load(taxaFile, 'taxa_code');
GroupSize = length(taxa_code);
chunk_size = 25;

%%% read rslt matrices and separate distance and landmarkMSE's
cPDistMatrix = zeros(GroupSize,GroupSize);
cPMapsMatrix = cell(GroupSize,GroupSize);
invcPMapsMatrix = cell(GroupSize,GroupSize);
%cPlmkMSEMatrix = zeros(GroupSize,GroupSize);
tmpTextureCoords1Matrix = cell(GroupSize,GroupSize);
tmpTextureCoords2Matrix = cell(GroupSize,GroupSize);

cnt = 0;
job_id = 0;
for k1=1:GroupSize
    progressbar(k1,GroupSize,20);
    for k2=1:GroupSize
        if mod(cnt,chunk_size)==0
            job_id = job_id+1;
            load([rslts_path 'rslt_mat_' num2str(job_id)]);
        end
        cPDistMatrix(k1,k2) = cPrslt{k1,k2}.cPdist;
        cPMapsMatrix{k1,k2} = cPrslt{k1,k2}.cPmap;
        invcPMapsMatrix{k1,k2} = cPrslt{k1,k2}.invcPmap;
        %cPlmkMSEMatrix(k1,k2) = cPrslt{k1,k2}.lkMSE;
        tmpTextureCoords1Matrix{k1,k2} = cPrslt{k1,k2}.TextureCoords1;
        tmpTextureCoords2Matrix{k1,k2} = cPrslt{k1,k2}.TextureCoords2;
        
        cnt = cnt+1;
    end
end

%%% symmetrize
cnt = 0;
job_id = 0;
for j=1:GroupSize
    progressbar(j,GroupSize,20);
    for k=1:GroupSize
        if mod(cnt,chunk_size)==0
            if cnt>0
                save([TextureCoords1Matrix_path 'TextureCoords1_mat_' num2str(job_id) '.mat'],'TextureCoords1Matrix');
                save([TextureCoords2Matrix_path 'TextureCoords2_mat_' num2str(job_id) '.mat'],'TextureCoords2Matrix');
                clear TextureCoords1Matrix TextureCoords2Matrix
            end
            job_id = job_id+1;
            TextureCoords1Matrix = cell(GroupSize,GroupSize);
            TextureCoords2Matrix = cell(GroupSize,GroupSize);
        end
        if cPDistMatrix(j,k)<cPDistMatrix(k,j)
            %cPlmkMSEMatrix(k,j) = cPlmkMSEMatrix(j,k);
            cPMapsMatrix{k,j} = invcPMapsMatrix{j,k};
            TextureCoords1Matrix{j,k} = tmpTextureCoords1Matrix{j,k};
            TextureCoords2Matrix{j,k} = tmpTextureCoords2Matrix{j,k};
        else
            %cPlmkMSEMatrix(j,k) = cPlmkMSEMatrix(k,j);
            cPMapsMatrix{j,k} = invcPMapsMatrix{k,j};
            TextureCoords1Matrix{j,k} = tmpTextureCoords2Matrix{k,j};
            TextureCoords2Matrix{j,k} = tmpTextureCoords1Matrix{k,j};
        end
        cnt = cnt+1;
    end
end
% if mod(cnt,chunk_size)~=0
save([TextureCoords1Matrix_path 'TextureCoords1_mat_' num2str(job_id) '.mat'],'TextureCoords1Matrix');
save([TextureCoords2Matrix_path 'TextureCoords2_mat_' num2str(job_id) '.mat'],'TextureCoords2Matrix');
clear TextureCoords1Matrix TextureCoords2Matrix
% end
cPDistMatrix = min(cPDistMatrix,cPDistMatrix');

%%% visualize distance and landmarkMSE matrices
%figure;
%imagesc(cPDistMatrix./max(cPDistMatrix(:))*64);
%axis equal;
%axis([1,GroupSize,1,GroupSize]);

%figure;
%imagesc(cPlmkMSEMatrix./max(cPlmkMSEMatrix(:))*64);
%axis equal;
%axis([1,GroupSize,1,GroupSize]);

%%% save results
save([result_path 'cPDistMatrix.mat'],'cPDistMatrix');
%save([result_path 'cPlmkMSEMatrix.mat'],'cPlmkMSEMatrix');
save([result_path 'cPMapsMatrix.mat'],'cPMapsMatrix');

