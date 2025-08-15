/*
-Hierarchical behavioural model for 2AFC data using contrast as input
-Includes ability to fit win-stay lose-switch effects
*/
data {
	int<lower=1> numTrials;
	int<lower=1> numSessions;
	int<lower=1> numSubjects;
	int<lower=1,upper=numSessions> sessionID[numTrials];
	int<lower=1,upper=numSubjects> subjectID[numTrials];
	vector<lower=0,upper=1>[numTrials] contrastLeft;
	vector<lower=0,upper=1>[numTrials] contrastRight;
	int<lower=0,upper=1> choice[numTrials]; // 0=Left, 1=Right
	int<lower=-1,upper=1> prevWin[numTrials]; // -1=Left, +1=Right
	int<lower=-1,upper=1> prevLose[numTrials]; // -1=Left, +1=Right
}
parameters {
	//global parameters
	real bias;
	real<lower=0> sens_left;
	real<lower=0> sens_right;
	real<lower=0,upper=1> sens_n_exp;
	real prevWinEffect;
	real prevLoseEffect;
	
	//per session deviations 
	vector<lower=0>[5] sd_sess;
	matrix[5,numSessions] z_sess; //standard normal variable used to draw from the covariance matrix
	cholesky_factor_corr[5] rho_sess; //correlations of deviations
	
	//per subject deviations
	vector<lower=0>[5] sd_subj;
	matrix[5,numSubjects] z_subj; 
	cholesky_factor_corr[5] rho_subj; 
}
transformed parameters {
	vector[numTrials] log_pRpL;
	matrix[5,numSessions] b_sess;
	matrix[5,numSubjects] b_subj;
	
	//draw samples of sess and subj deviations, according to the covariance structure in rho_ & sd_
	b_sess = diag_pre_multiply(sd_sess, rho_sess) * z_sess;
	b_subj = diag_pre_multiply(sd_subj, rho_subj) * z_subj;

	{
		//temp variables
		real B;
		real SL;
		real SR;
		real H; //history term
		
		//compute (non)linear model
		for (n in 1:numTrials)
		{
			B  = bias 		+ b_sess[1,sessionID[n]] + b_subj[1,subjectID[n]];
			SL = sens_left  + b_sess[2,sessionID[n]] + b_subj[2,subjectID[n]];
			SR = sens_right + b_sess[3,sessionID[n]] + b_subj[3,subjectID[n]];
			
			if (prevWin[n] != 0 ) { //if previous trial was a win
				H = prevWinEffect  + b_sess[4,sessionID[n]] + b_subj[4,subjectID[n]];
			} else { //else previous trial was a loss
				H = prevLoseEffect + b_sess[5,sessionID[n]] + b_subj[5,subjectID[n]];
			}

			log_pRpL[n] = B + SL*(contrastLeft[n]^sens_n_exp) + SR*(contrastRight[n]^sens_n_exp) + H;
		}
	}
}
model {
	//priors on global parameters
	bias 		~ normal(0, 2);
	sens_left	~ normal(4, 3);
	sens_right	~ normal(4, 3);
	sens_n_exp	~ normal(0.6,0.3);
	prevWinEffect ~ normal(0, 2);
	prevLoseEffect ~ normal(0, 2);
	
	//make z_std_normal be standard normal (non centred parameterisation)
	to_vector(z_sess) ~ normal(0, 1);	
	to_vector(z_subj) ~ normal(0, 1);	
	
	//prior on the variation of the per-session deviations
	sd_sess ~ cauchy(0,1);
	sd_subj ~ cauchy(0,1);
	
	//prior on the cholesky factor of the covariance matrix
	rho_sess ~ lkj_corr_cholesky(2.0); //penalises extreme correlations between the deviations
	rho_subj ~ lkj_corr_cholesky(2.0); //penalises extreme correlations between the deviations

	//likelihood function
	choice ~ bernoulli_logit( log_pRpL );
}
generated quantities {
	corr_matrix[5] corr_sess;
	corr_matrix[5] corr_subj;
	vector[numTrials] log_lik;
	
	//write correlation matrix
	corr_sess = rho_sess * rho_sess';
	corr_subj = rho_subj * rho_subj';

	//write loglik
	for (n in 1:numTrials){
		log_lik[n] = bernoulli_logit_lpmf(choice[n] | log_pRpL[n] );
	} 
}