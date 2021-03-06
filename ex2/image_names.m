%File containing file names image names, run params etc.
%the name of the folder for one day at the lab
day_folder = [  "MEK4600_G3_21_10_02";
                "MEK4600_G3_21_10_02";
                "MEK4600_G3_21_10_02";
                "MEK4600_G3_21_10_02";
                "MEK4600_G3_21_10_02";
                "MEK4600_G3_21_17_02";
                "MEK4600_G3_21_17_02";
                "MEK4600_G3_21_17_02";
                "MEK4600_G3_21_17_02";
                "MEK4600_G3_21_17_02";
                "MEK4600_G3_21_24_02";
                "MEK4600_G3_21_24_02";
                "MEK4600_G3_21_24_02";
                "MEK4600_G3_21_24_02";
                "MEK4600_G3_21_24_02"];

%the name of the folder for the run
run_folder = ["2021-02-10_run1_C001H001S0001";
                "2021-02-10_run2_C001H001S0001";
                "2021-02-10_run3_C001H001S0001";
                "2021-02-10_run4_C001H001S0001";
                "2021-02-10_run5_C001H001S0001";
                "2021-02-17_run6_C001H001S0001";
                "2021-02-17_run7_C001H001S0001";
                "2021-02-17_run8_C001H001S0001";
                "2021-02-17_run9_C001H001S0001";
                "2021-02-17_run10_C001H001S0001";
                "2021-02-24_run11_C001H001S0001";
                "2021-02-24_run12_C001H001S0001";
                "2021-02-24_run13_C001H001S0001";
                "2021-02-24_run14_C001H001S0001";
                "2021-02-24_run15_C001H001S0001"];

% %folders for storing the masks
% for i=1:size(day_folder, 1)
%    temp = mkdir('masks/' + day_folder(i) + '/' + run_folder(i));
% end

            
            
%The number for two consecutive images with the wave in the middle of the
%image. With three pairs of images for each run.     %run number
image_pairs = [ "159" "160" "373" "374" "445" "446"; %1
                "019" "020" "123" "124" "192" "193"; %2
                "072" "073" "096" "097" "149" "150"; %3
                "007" "008" "033" "034" "060" "061"; %4
                "013" "014" "047" "048" "080" "081"; %5
                "029" "030" "062" "063" "165" "166"; %6
                "028" "029" "062" "063" "096" "097"; %7
                "040" "041" "095" "096" "122" "123"; %8 %%%%
                "017" "018" "044" "045" "070" "071"; %9
                "015" "016" "049" "050" "084" "085"; %10
                "029" "030" "063" "064" "095" "096"; %11
                "040" "041" "075" "076" "109" "110"; %12
                "037" "038" "071" "072" "105" "106"; %13
                "037" "038" "064" "065" "091" "092"; %14
                "032" "033" "058" "059" "085" "086";]; %15

%Fill image_name with the names of the images
image_name = string(zeros(size(run_folder, 2), 6));
for i=1:size(run_folder, 1)
    for j=1:size(image_pairs, 2)
        image_name(i,j) = day_folder(i,:) + "/" + run_folder(i) + "/" + run_folder(i) +  "000" + image_pairs(i,j) + ".bmp";
    end
end

% the heights of the water level in the tank
heights = ones(15, 1)*0.335;

%the frequencies for the runs
frequency = [1.75;1.75;2.25;2.25;1.75;
            1.75;1.75;2.25;2.25;1.75;
            1.75;1.75;1.75;2.25;2.25];
% the run numbers that are run with the same parameters are in the same row
% for making means over the runs with the same parameters.
run_numbers_same_params = [1 5 12;
                            2 10 13;
                            3 8 15;
                            4 9 14;
                            6 7 11];
        
%the start and stop indices for the measuring of the surface elevation
surface_start_stop = [  1000 2000;%can check first ones
                        1000 2000;
                        800 2000;
                        800 2000;
                        200 2000;
                        300 2000;
                        700 2000;
                        400 2000;
                        650 2000;
                        1000 2000;
                        1000 2000;
                        1000 2000;
                        1000 2000;
                        1000 2000;
                        1200 2000];