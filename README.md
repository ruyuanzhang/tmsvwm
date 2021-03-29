# TMSVWM
This is the matlab code repository for TMS visual working memory (TMVWM) project. The main contributor for this project is [Ru-Yuan Zhang](ruyuanzhang@gmail.com), Hao-Jiang Ying, and Fei Wang.

## History

* 2021/03/29 RYZ 
  * add cpsfigure.m
  * Randomize set size [1 3] and [5 8]
* 2020/11/26 RYZ made several changes
  * set size change to [1 3 5 8], trial numbers changed to [60 120 120 60]
  * set 4-s response window
* 2019/09/11 RYZ fixed the bugs 
* 2019/07/01 RYZ created the github repository


## Instructions of running experiments
### Preparation
1. Please download utility functions from [RZutil](https://github.com/ruyuanzhang/RZutil), and add the functions to your matlab path.

2. Make sure you have a proper measure of your monitor. You need to input the screen size, resolution, and view distance.

### Running experiment
1. For each run, simply type below to run the experiment. It needs to input the number of stimuli (e.g., 1,3,6)

	```matlab
	>> VWM_rect_new_rz.m
	Please the subject initial (e.g., RYZ or RZ)?: RYZ
	Please choose the exp (1, main exp; 0, practice): 1
	```


2. Data will be automatically saved with time stamp.

### Research plan

* day 1, practice, sham (set size = 1, 3, 5, 8, 120 trials each block)
* day 2, Real IPS (set size = 1, 3, 5, 8)
* day 3, Real V1 (set size = 1, 3, 5, 8)
* day 4. Real DLPFC (set size = 1, 3, 5, 8)

Notes:

* The sham, IPS, V1 and DLPFC should be lartin squared counter balanced acorss subjects
* The order of set size should also be randomised 



# Research progress and thoughts
