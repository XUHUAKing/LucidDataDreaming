%cd lucid_data_dreaming

addpath(genpath('src'));
%% inpainting
addpath(genpath('patch-inpainting'));
%% blending
addpath(genpath('PoissonEdiitng'));


% the path for annotation (i.e. mask) and image 
annotations_path = 'DAVIS/Annotations/Full-Resolution';
images_path = 'DAVIS/JPEGImages/Full-Resolution/';
image_set_path = 'DAVIS/ImageSets/2017/val.txt';
aug_annotations_path = 'DAVIS/Annotations_aug/Full-Resolution';
aug_images_path = 'DAVIS/JPEGImages_aug/Full-Resolution';
% the number of augmented images for each first frame
aug_num = 256;

if ~exist(aug_annotations_path, 'dir')
    mkdir(aug_annotations_path);
end
if ~exist(aug_images_path, 'dir')
    mkdir(aug_images_path);
end

% get video sequence names
seq_names = dataread('file', image_set_path, '%s', 'delimiter', '\n');
% get first frames
annotations_files = dir([annotations_path '**/00000.png']);
images_files = [dir([images_path '**/00000.jpg']); dir([images_path '**/00000.jpeg'])];

%% data dreaming
for i = 1:length(annotations_files)
   cur_seq = split(annotations_files(i).folder, '\');
   cur_seq_name = char(cur_seq(end));
   if ~any(strcmp(seq_names, cur_seq_name))
       % skip this sequence
       continue
   end
   fprintf('working on current seq name %s \n', cur_seq_name);
   
   % read image and gt
   img = imread(strcat(images_files(i).folder, '/', images_files(i).name));
   gt = imread(strcat(annotations_files(i).folder, '/', annotations_files(i).name));
   
   % generate aug_num = 256 augmented images for each pair of image and gt
   bg = '';
   for j = 1:aug_num
       img_name = split(images_files(i).name, '.');
       gt_name = split(annotations_files(i).name, '.');
       new_img_name = strcat(char(img_name(1)), '_', num2str(j-1));
       new_gt_name = strcat(char(gt_name(1)), '_', num2str(j-1));
       
       % generate a new synthetic image
       [im1, gt1, prev_mask1, bg1] = lucid_dream(img,gt,0,bg);
       % reuse background image to accelerate
       bg = bg1;
       
       % TODO: convert gt from gray image to rgb
       % save new img and gt
       imwrite(im1, [strcat(images_files(i).folder, '/', new_img_name), '.jpg']);
       imwrite(gt1, [strcat(annotations_files(i).folder, '/', new_gt_name), '.png']);
   end
end