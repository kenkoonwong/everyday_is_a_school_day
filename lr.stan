data {
  int<lower=0> N;
  vector[N] x;
  vector[N] y;
  vector[N] w;
  vector[N] collider;
}
parameters {
  real a_y;
  real b_yx;
  real b_yw;
  real a_collider;
  real b_collider_x;
  real b_collider_y;
  real<lower=0> sigma_y;
  real<lower=0> sigma_collider;
  }
model {
  // prior
  a_y ~ uniform(-1,1);
  b_yx ~ normal(10,1);
  
  // likelihood
  y ~ normal(a_y + b_yx * x + b_yw * w, sigma_y);
  collider ~ normal(a_collider + b_collider_x * x + b_collider_y * y, sigma_collider);
}
