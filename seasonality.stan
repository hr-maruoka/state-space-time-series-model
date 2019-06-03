data {
  int T;
  vector[T] Y;
  int T_pred;
}

parameters {
  vector[T] month;
  vector[T] mu;
  
  real<lower=0> s_month;
  real<lower=0> s_mu;
  real<lower=0> s_Y;
}

transformed parameters {
  vector[T-11] former_month;
  
  for (t in 12:T)
    former_month[t-11] = sum(month[t-11:t-1]);
}

model {
  month[12:T] ~ normal(-former_month[1:T-11], s_month);
  mu[3:T] ~ normal(2 * mu[2:T-1] - mu[1:T-2], s_mu);
  Y ~ normal(month + mu, s_Y);
}

generated quantities{
  vector[T + T_pred] month_all;
  vector[T + T_pred] mu_all;
  real y_pred[T_pred];
  
  mu_all[1:T] = mu;
  month_all[1:T] = month ;
  
  for (t in 1:T_pred){
    month_all[T+t] = normal_rng(-sum(month_all[T+t-11:T+t-1]), s_month);
    mu_all[T+t] = normal_rng(2 * mu_all[T+t-1] - mu_all[T+t-2], s_mu);
    y_pred[t] = normal_rng(month_all[T+t] + mu_all[T+t], s_Y);
  }
}
