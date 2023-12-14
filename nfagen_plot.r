#
# Copyright 2023 Erwan Mahe (github.com/erwanM974)
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#     http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

rm(list=ls())
# ==============================================
library(ggplot2)
library(scales)
library(patchwork)
# ==============================================

# ==============================================
read_csv <- function(file_path) {
  # ===
  report <- read.table(file=file_path, 
                       header = FALSE, 
                       sep = ",",
                       blank.lines.skip = TRUE, 
                       fill = TRUE)
  
  names(report) <- as.matrix(report[1, ])
  report <- report[-1, ]
  report[] <- lapply(report, function(x) type.convert(as.character(x)))
  report
}
# ==============================================



# ==============================================
prepare_data <- function(mydata) {
  mydata <- data.frame( mydata )
  #
  mydata$Empty <- as.numeric(mydata$Empty)
  mydata$Action <- as.numeric(mydata$Action)
  
  mydata <- dplyr::filter(mydata, Action <= 50)
  
  mydata$Strict <- as.numeric(mydata$Strict)
  mydata$Seq <- as.numeric(mydata$Seq)
  mydata$Alt <- as.numeric(mydata$Alt)
  mydata$LoopS <- as.numeric(mydata$LoopS)
  mydata$Par <- as.numeric(mydata$Par)
  #
  mydata$Symbols <- mydata$Empty + mydata$Action + mydata$Strict + mydata$Seq + mydata$Alt + mydata$LoopS + mydata$Par
  #
  mydata$operatnumstates <- as.numeric(mydata$operatnumstates)
  mydata$componumstates <- as.numeric(mydata$componumstates)
  mydata$kind <- as.factor(mydata$kind)
  #
  mydata
}
# ==============================================

# ==============================================
geom_ptsize = 1
geom_stroke = 1
# ===
set_plot_common_scales <- function(g,
                                   max_x,
                                   max_y) {
  par_fun <- function(x) {ifelse(x>1,2**x,2)}
  strict_fun <- function(x) {ifelse(x>1,x+1,2)}
  p8_fun <- function(x) {ifelse(x>9,(2**8)*(x-7)+1,par_fun(x))}
  p7_fun <- function(x) {ifelse(x>8,(2**7)*(x-6)+1,par_fun(x))}
  p6_fun <- function(x) {ifelse(x>7,(2**6)*(x-5)+1,par_fun(x))}
  p5_fun <- function(x) {ifelse(x>6,(2**5)*(x-4)+1,par_fun(x))}
  p4_fun <- function(x) {ifelse(x>5,(2**4)*(x-3)+1,par_fun(x))}
  p3_fun <- function(x) {ifelse(x>4,(2**3)*(x-2)+1,par_fun(x))}
  p2_fun <- function(x) {ifelse(x>3,(2**2)*(x-1)+1,par_fun(x))}
  p1_fun <- function(x) {ifelse(x>2,(2*x)+1,par_fun(x))}
  g +
    coord_cartesian(
      xlim = c(2, max_x),
      ylim = c(1.5, max_y), 
      expand = TRUE) +
    xlim(1, max_x) +
    geom_function(fun=par_fun) + 
    geom_function(fun=strict_fun,alpha = 5/10) +
    geom_function(fun=p1_fun,alpha = 5/10)+
    geom_function(fun=p2_fun,alpha = 5/10)+
    geom_function(fun=p3_fun,alpha = 5/10)+
    geom_function(fun=p4_fun,alpha = 5/10)+
    geom_function(fun=p5_fun,alpha = 5/10)+
    geom_function(fun=p6_fun,alpha = 5/10)+
    geom_function(fun=p7_fun,alpha = 5/10)+
    geom_function(fun=p8_fun,alpha = 5/10)+
    scale_color_manual(
      name='kind',
      breaks=c('LoopAltNoPar',
               'LoopAlt',
               'Random',
               'RandomNoPar', 
               'Doors', 
               'DoorsNoPar'
      ),
      values=c('LoopAlt'='darkorchid',
               'LoopAltNoPar'='pink',
               'Random'='darkgreen', 
               'RandomNoPar'='chartreuse', 
               'Doors'='red',
               'DoorsNoPar'='darkorange'
      )
    ) + 
    scale_shape_manual(
      values = c("LoopAlt" = 5,
                 "LoopAltNoPar" = 5,
                 'Random'=15, 
                 'RandomNoPar'=15, 
                 'Doors'=15, 
                 'DoorsNoPar'=15
      )
    ) +
    scale_y_log10() +
    theme(
      legend.position="none",
      axis.text.y = element_text(angle=90),
      axis.title.y=element_blank(),
      axis.title.x=element_blank(),
      plot.margin = unit(c(0.1,0.1,0.1,0.1), "cm")
    )
}
# ===


# ===
get_patchwork <- function(report_data,
                          max_x,
                          max_y) {
  
  #
  g1 <- ggplot(data=report_data) + 
    geom_point(
      aes(x = Action, y = operatnumstates, color = kind, shape = kind),
      size = geom_ptsize,
      stroke = geom_stroke
    )
  
  #
  g2 <- ggplot(data=report_data) + 
    geom_point(
      aes(x = Action, y = componumstates, color=kind, shape = kind),
      size = geom_ptsize,
      stroke = geom_stroke
    )
  
  #
  g1 <- set_plot_common_scales(g1,max_x,max_y)
  
  g2 <- set_plot_common_scales(g2,max_x,max_y) +
    theme(axis.text.y=element_blank())
  
  g1 + g2
}

# ===
get_grid <- function(report_data,
                     max_x,
                     max_y) {
  par_fun <- function(x) {ifelse(x>1,2**x,2)}
  strict_fun <- function(x) {ifelse(x>1,x+1,2)}
  p8_fun <- function(x) {ifelse(x>9,(2**8)*(x-7)+1,par_fun(x))}
  p7_fun <- function(x) {ifelse(x>8,(2**7)*(x-6)+1,par_fun(x))}
  p6_fun <- function(x) {ifelse(x>7,(2**6)*(x-5)+1,par_fun(x))}
  p5_fun <- function(x) {ifelse(x>6,(2**5)*(x-4)+1,par_fun(x))}
  p4_fun <- function(x) {ifelse(x>5,(2**4)*(x-3)+1,par_fun(x))}
  p3_fun <- function(x) {ifelse(x>4,(2**3)*(x-2)+1,par_fun(x))}
  p2_fun <- function(x) {ifelse(x>3,(2**2)*(x-1)+1,par_fun(x))}
  p1_fun <- function(x) {ifelse(x>2,(2*x)+1,par_fun(x))}
  
  ggplot(data=report_data) + 
    geom_point(
      aes(x = Action, y = operatnumstates),
      size = geom_ptsize,
      stroke = geom_stroke,
      shape=1
    ) +
    coord_cartesian(
      xlim = c(2, max_x),
      ylim = c(1.5, max_y), 
      expand = TRUE) +
    xlim(1, max_x) +
    scale_y_log10() +
    theme(
      legend.position="none",
      axis.text.y = element_text(angle=90),
      axis.title.y=element_blank(),
      axis.title.x=element_blank(),
      plot.margin = unit(c(0.1,0.1,0.1,0.1), "cm")
    ) + 
    geom_function(fun=par_fun) + 
    geom_function(fun=strict_fun,alpha = 3/10) +
    geom_function(fun=p1_fun,alpha = 3/10)+
    geom_function(fun=p2_fun,alpha = 3/10)+
    geom_function(fun=p3_fun,alpha = 3/10)+
    geom_function(fun=p4_fun,alpha = 3/10)+
    geom_function(fun=p5_fun,alpha = 3/10)+
    geom_function(fun=p6_fun,alpha = 3/10)+
    geom_function(fun=p7_fun,alpha = 3/10)+
    geom_function(fun=p8_fun,alpha = 3/10)
}
# ===


report_data <- read_csv("./precomputed_data.csv")
report_data <- prepare_data(report_data)

maxcompo <- max(report_data$componumstates)
maxoperat <- max(report_data$operatnumstates)

max_y <- max(maxcompo,maxoperat)
max_x <- max(report_data$Action)


doors_only <- report_data[(report_data$kind == 'Doors')|(report_data$kind == 'DoorsNoPar'),]
random_only <- report_data[(report_data$kind == 'Random')|(report_data$kind == 'RandomNoPar'),]
loopalt_only <- report_data[(report_data$kind == 'LoopAlt')|(report_data$kind == 'LoopAltNoPar'),]


strict_par_only <- report_data[
  (report_data$kind != 'Doors')&(report_data$kind != 'DoorsNoPar')
  &(report_data$kind != 'Random')&(report_data$kind != 'RandomNoPar')
  &(report_data$kind != 'LoopAlt')&(report_data$kind != 'LoopAltNoPar'),
  ]

g_doors <- get_patchwork(doors_only,max_x,max_y)
g_random <- get_patchwork(random_only,max_x,max_y)
g_loopalt <- get_patchwork(loopalt_only,max_x,max_y)
g_strictpar <- get_grid(strict_par_only,max_x,max_y)

ggsave("grid.png", g_strictpar, width = 1750, height = 2000, units = "px")
ggsave("random.png", g_random, width = 3750, height = 2000, units = "px")
ggsave("doors.png", g_doors, width = 3750, height = 2000, units = "px")
ggsave("loopalt.png", g_loopalt, width = 3750, height = 2000, units = "px")


