# commands to wrangle the classification column in QuPath measurements
# for quantification of multiple markers

require(tidyverse)

# before running these commands, load a dataframe as df (QuPath detection measurements)

# show all classifications in the file
# --might be dozens if you have many labels
unique(df$Classification)

# note: 
#   grepl returns a logical vector (same length as target)
#   grepl can be used with the ! (NOT) operator
#   alternatively, grep returns a vector of indices (length = the number of matches)

# collect all cells that contain, or do not contain CK 
# (note that the string we search for must be unique = not part of the name of any other classification)
CK_pos <- df %>% filter(grepl("CK", Classification))
CK_neg <- df %>% filter(!grepl("CK", Classification))

# collect all cells that are double positive CD68:PDL1 (regardless of other classes)
CD68_PDL1 <- df %>% filter(grepl("CD68", Classification)) %>% 
  filter(grepl("PDL1", Classification))

# double check what classifications we get with this filter
# -- they should all have both CD68 and PDL1
unique(CD68_PDL1$Classification)

# count and measure fraction positive for CD68 and PDL1
double_pos_count <- nrow(CD68_PDL1)
total_count <- nrow(df)
frac_double_pos <- double_pos_count/total_count

# stratify by CK positivity using grep
# -- note that this method does not give you a separate dataframe with the matches
double_pos_CK_count <- length(grep("CK", CD68_PDL1$Classification))

# Fraction of double positive cells that are CK+
frac_double_pos_CK <- double_pos_CK_count/double_pos_count

# Fraction of all cells that are CK+
frac_CK <- nrow(CK_pos)/total_count



# Fraction of CK+ cells that are double positive
CK_double_pos <- CK_pos %>% filter(grepl("CD68", Classification)) %>% 
  filter(grepl("PDL1", Classification))
frac_CK_double_pos <- nrow(CK_double_pos)/nrow(CK_pos)


