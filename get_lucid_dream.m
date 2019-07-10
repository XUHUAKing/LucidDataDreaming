%cd lucid_data_dreaming

addpath(genpath('src'));
%% inpainting
addpath(genpath('patch-inpainting'));
%% blending
addpath(genpath('PoissonEdiitng'));


% the path for annotation (i.e. mask) and image 
annotations_path = 'annotations/';
images_path = 'images/';
image_set_path = 'val.txt';
aug_annotations_path = 'annotations_aug/';
aug_images_path = 'images_aug/';
% the number of augmented images for each first frame
aug_num = 5;

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
for i = 1:length(seq_names)
   cur_seq_name = char(seq_names(i));  
   gt_path = strcat(annotations_path, cur_seq_name, '/', '00000.png');
   img_path = strcat(images_path, cur_seq_name, '/', '00000.jpg');
   
   % read image and gt
   img = imread(img_path);
   gt = imread(gt_path);
   
   if isempty(img) || isempty(gt)
       continue
   end
   fprintf('working on current seq name %s \n', cur_seq_name);
   
   % generate aug_num = 256 augmented images for each pair of image and gt
   bg = '';
   for j = 1:aug_num
       new_img_name = strcat('00000_', num2str(j-1));
       new_gt_name = strcat('00000_', num2str(j-1));
       
       % generate a new synthetic image
       [im1, gt1, prev_mask1, bg1] = lucid_dream(img,gt,0,bg);
       % reuse background image to accelerate
       bg = bg1;
       
       % TODO: convert gt from gray image to rgb
       % save new img and gt
       imwrite(gt1, [strcat(aug_annotations_path, cur_seq_name, '/', new_gt_name), '.png']);
       imwrite(im1, [strcat(aug_images_path, cur_seq_name, '/', new_img_name), '.jpg']);
   end
end