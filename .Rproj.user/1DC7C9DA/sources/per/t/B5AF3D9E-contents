library(colorspace)
library(tidyverse)
theme_set(theme_bw())

source('./R/01_ecto_modeling.R')
source('./R/02_mesotherm_modeling.R')
source('./R/03_meg_modeling.R')
source('./R/04_white_shark_modeling.R')
source('./R/05_endo_modeling.R')
source('./R/06_ecto_ungrouped_modeling.R')
source('./R/07_endo_grouped_modeling.R')
source('./R/08_chub_modeling.R')

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
chub <- read_csv(file = './data/chubutensis_posterior.csv') %>% 
  mutate(thermo = 'chubutensis')
burn <- 1000

all <- rbind(ecto,
             meso, 
             meg, 
             white,
             endo_ungrouped,
             ecto_ungrouped,
             endo_grouped,
             chub)

# pdf(file = 'model_summary.pdf', width = 6.5, height = 9.5)
# 
# all %>% 
#   filter(!(thermo %in% c('endo_ungrouped', 'ecto_ungrouped'))) %>% 
#   filter(iteration > burn) %>% 
#   ggplot(mapping = aes(x = temperature,
#                        fill = thermo,
#                        group = thermo)) + 
#   geom_density(alpha = 0.75,
#                adjust = 2) + 
#   facet_wrap(~group,
#              scales = 'free_y',
#              ncol = 1) + 
#   scale_fill_discrete_sequential(palette = 'Sunset') + 
#   theme(legend.position = 'top',
#         axis.text.y = element_blank())
# 
# dev.off()

all %>% 
  group_by(group, 
           thermo) %>% 
  summarize(d18Ow_mean = mean(d18Ow),
            d18Ow_sd   = sd(d18Ow),
            temperature_mean = mean(temperature),
            temperature_sd = sd(temperature)) %>% 
  mutate_if(is.numeric, round, 1) %>%  
  write_csv(file = './data/all_model_summary.csv')


all <- all %>% 
  filter(!(thermo %in% c('ecto_ungrouped', 'endo_ungrouped'))) %>% 
  mutate(age = case_when(
    group == "miocene_california" ~ 'Miocene', 
    group == "miocene_north_carolina" ~ 'Miocene', 
    group == "miocene_japan" ~ 'Miocene', 
    group == "miocene_germany" ~ 'Miocene', 
    group == "pliocene_japan" ~ 'Pliocene',
    group == "pliocene_north_carolina" ~ 'Pliocene',
    group == "miocene_italy" ~ 'Pliocene',
  )) %>% 
  mutate(location = case_when(
    group == "miocene_california" ~ 'California', 
    group == "miocene_north_carolina" ~ 'North Carolina', 
    group == "miocene_japan" ~ 'Japan', 
    group == "miocene_germany" ~ 'Germany', 
    group == "pliocene_japan" ~ 'Japan',
    group == "pliocene_north_carolina" ~ 'North Carolina',
    group == "miocene_italy" ~ 'Malta')) %>% 
  mutate(age = factor(age, levels = c('Pliocene', 'Miocene'))) %>% 
  mutate(thermo = factor(thermo, levels = rev(c('megalodon', 
                                            'chubutensis',
                                            'white_shark',
                                            'endo_grouped',
                                            'meso',
                                            'ecto'))))


labels <- c('white_shark' = expression(italic('C. carcharias')),
            'meso' = 'mesothermic', 
            'megalodon' = expression(italic('O. megalodon')),
            'chubutensis' = expression(italic('O. chubutensis')),
            'endo_grouped' = 'endothermic',
            'ecto' = 'ectothermic')

pdf(file = 'posterior_figure.pdf',
    width = 6.5,
    height = 3)
all %>% 
  group_by(group, thermo, age, location) %>% 
  summarize(t_mean = mean(temperature),
            t_sd   = sd(temperature)) %>% 
  ggplot(mapping = aes(y = thermo,
                       x = t_mean,
                       color = thermo)) + 
  geom_linerange(mapping = aes(xmin = t_mean - t_sd,
                               xmax = t_mean + t_sd),
                 
                 size = 2) + 
  geom_linerange(mapping = aes(xmin = t_mean - 2*t_sd,
                               xmax = t_mean + 2*t_sd),
                 size = 1) + 
  geom_point(size = 2.25) + 
  facet_grid(age~location) + 
  theme(legend.position = 'none',
        axis.text = element_text(size = 10,
                                 color = 'black'),
        axis.title = element_text(size = 10,
                                  color = 'black'),
        strip.background = element_blank(),
        axis.title.y = element_blank(),
        strip.text = element_text(size = 10,
                                  color = 'black')) + 
 scale_color_discrete_sequential(palette = 'SunsetDark') + 
  xlab('Temperature (C)') + 
  xlim(10, 50) + 
  scale_y_discrete(labels = labels)
dev.off()

