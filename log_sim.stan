data {
  int N;
  array[N] int x;
  array[N] int y;
  array[N] real w;
  array[N] real collider;
}

parameters {
  real alpha_y;
  real beta_yx;
  real beta_yw;
  real alpha_collider;
  real beta_collider_x;
  real beta_collider_y;
  real sigma_collider;

}

model {
  // prior

  
  // likelihood

    y ~ bernoulli_logit(alpha_y + beta_yx * to_vector(x) + beta_yw * to_vector(w));
    collider ~ normal(alpha_collider + beta_collider_x * to_vector(x) + beta_collider_y * to_vector(y), sigma_collider);
  
}


