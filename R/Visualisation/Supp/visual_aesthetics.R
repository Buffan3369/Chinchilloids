library(tidyverse)

## Gaussian --------------------------------------------------------------------
x <- seq(-5, 5, 0.001)
y <- sapply(x, FUN = function(x){1/(sqrt(2*pi))*exp((-x**2)/2)})
plt_df <- data.frame(x, y)

p <- plt_df %>%
  ggplot(aes(x = x, y = y)) +
  geom_line() +
  geom_ribbon(aes(ymax = y, ymin = 0), fill = "transparent") +
  scale_y_continuous(expand = c(0,0), limits = c(0,0.6)) +
  scale_x_continuous(limits = c(-3.5, 3.5)) +
  theme(axis.line.x = element_blank(),
        axis.ticks = element_blank(),
        axis.line.y = element_blank(),
        axis.text = element_blank(),
        axis.title = element_blank(),
        panel.grid.major = element_blank(),
        panel.background = element_blank(),
        panel.grid.minor = element_blank())

ggsave("./Figures/Supp/extant_sampling/gaussian.pdf", plot = p, height = 30, width = 30, units = "mm")
