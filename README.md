# TMSVWM
This is the matlab code repository for TMS visual working memory (TMVWM) project. The main contributor for this project is [Ru-Yuan Zhang](ruyuanzhang@gmail.com), Hao-Jiang Ying, and Fei Wang.

## History
* 2019/09/11 RZ fixed the bugs 
* 2019/07/01 RZ created the github repository


## Instructions of running experiments
### Preparation
1. Please download utility functions from [RZutil](https://github.com/ruyuanzhang/RZutil), and add the functions to your matlab path.

2. Make sure you have the proper measure of your monitor. The key factor is ***scale_factor***, which indicates how many acrmin in one screen pixel.

### Running experiment
1. For each run, simply type below to run the experiment. It needs to input the number of stimuli (e.g., 1,3,6)

	```matlab
	>> VWM_rect_new_rz.m
	Please input the number of stimuli: 3
	```


2. Data will be automatically saved with time stamp.

### Research plan
* day 1, practice (set size = 2, 50 trials), sham (set size = 2, 4, 6, 120 trials each block)
* day 2, Real IPS (set size = 2, 4, 6)
* day 3, Real V1 (set size = 2, 4, 6)
* day 4. Real DLPFC (set size = 2, 4, 6)

Notes:

* The sham, IPS, V1 and DLPFC should be lartin squared counter balanced acorss subjects
* The order of set size should also be randomised 



# Research progress and thoughts
