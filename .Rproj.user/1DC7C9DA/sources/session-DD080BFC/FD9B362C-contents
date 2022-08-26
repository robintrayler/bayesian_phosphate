library(colorspace)
library(tidyverse)

source('./R/01_ecto_modeling.R')
source('./R/02_mesotherm_modeling.R')
source('./R/03_meg_modeling.R')
source('./R/04_white_shark_modeling.R')
source('./R/05_endo_modeling.R')
source('./R/06_ecto_ungrouped_modeling.R')
source('./R/07_endo_grouped_modeling.R')

theme_set(theme_minimal())
ecto <- read_csv(file = './data/ecto_posterior.csv') %>% 
  mutate(thermo = 'ecto')
meso <- read_csv(file = './data/meso_posterior.csv') %>% 
  mutate(thermo = 'meso')
meg <- read_csv(file = './data/meg_posterior.csv') %>% 
  mutate(thermo = 'megalodon')
white <- read_csv(file = './data/white_posterior.csv') %>% 
  mutate(thermo = 'white_shark')
endo_ungrouped <- read_csv(file = './data/endo_ungrouped_posterior.csv') %>% 
  mutate(thermo = 'endo_ungrouped')
endo_grouped <- read_csv(file = './data/endo_grouped_posterior.csv') %>% 
  mutate(thermo = 'endo_grouped')
ecto_ungrouped <- read_csv(file = './data/ecto_ungrouped_posterior.csv') %>% 
  mutate(thermo = 'ecto_ungrouped')
burn <- 5000

all <- rbind(ecto,
             meso, 
             meg, 
             white,
             endo_ungrouped,
             ecto_ungrouped,
             endo_grouped)

pdf(file = 'model_summary.pdf', width = 6.5, height = 9.5)

all %>% 
  filter(!(thermo %in% c('endo_ungrouped', 'ecto_ungrouped'))) %>% 
  filter(iteration > burn) %>% 
  ggplot(mapping = aes(x = temperature,
                       fill = thermo,
                       group = thermo)) + 
  geom_density(alpha = 0.75,
              adjust = 2) + 
  facet_wrap(~group,
             scales = 'free_y',
             ncol = 1) + 
  scale_fill_discrete_sequential(palette = 'Sunset') + 
  theme(legend.position = 'top',
        axis.text.y = element_blank())

dev.off()



all %>% 
  filter(group == 'miocene_japan') %>% 
  filter(thermo == 'megalodon') %>% 
  summarize(mean = mean(d18Op_modeled),
            sd = sd(d18Op_modeled))

all %>% 
  group_by(group, 
           thermo) %>% 
  summarize(d18Ow_mean = mean(d18Ow),
            d18Ow_sd   = sd(d18Ow),
            temperature_mean = mean(temperature),
            temperature_sd = sd(temperature)) %>% 
  mutate_if(is.numeric, round, 1) %>%  
  write_csv(file = './data/all_model_summary.csv')
