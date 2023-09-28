data {
  int<lower=0> N;
  array[N] int x;
  array[N] real w;
  real alpha_y;
  real beta_yx;
  real beta_yw;
}

// parameters {
//   array[N] real y_pred;
// }

generated quantities {
  array[N] real<lower=0,upper=1> y_pred;
  
  for (i in 1:N) {
    y_pred[i] = inv_logit(alpha_y + beta_yx * x[i] + beta_yw * w[i]);
}
}
