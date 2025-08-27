#R4DS 2nd edition teaching script
#this script is based on R for Data Science https://r4ds.hadley.nz/
#suggested answers for book problems can be found here: https://mine-cetinkaya-rundel.github.io/r4ds-solutions

#Hands-On Programming with R is also a good resource: https://rstudio-education.github.io/hopr/

####Setup Block####
##the first block of code in any R script should (minimally) be a setup block that:
#installs packages
#loads libraries
#sets your working directory

#we will use this script for several sessions.  It is important that the first thing you do is to run the setup block.

#package installs
#this syntax checks if a package is installed, installs it if not.

if (!require('tidyverse')) install.packages('tidyverse')
if (!require('palmerpenguins')) install.packages('palmerpenguins')
if (!require('nycflights13')) install.packages('nycflights13')
if (!require('rstudioapi')) install.packages('rstudioapi')
if (!require('readxl')) install.packages('readxl')
if (!require('ggthemes')) install.packages('ggthemes')
if (!require('readxl')) install.packages('readxl')
if (!require('babynames')) install.packages('babynames')
if (!require('words')) install.packages('words')

#library loadings
library(tidyverse)
library(palmerpenguins)
library(rstudioapi)
library(nycflights13)
library(readxl)
library(ggthemes)
library(babynames)
library(words)


#setting a working directory
#following command assumes you have rstudioapi installed/loaded and sets working directory to script directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

####Basics####

#The four panes: Script/Environment/File/Console
#Relationship between script and console panes
#enter 1+1 in console pane below
#next, run the next line
1+1

#line numbers
100:130

##combine, vectors, and lists
#This is a vector
c(100:130)
#This is a forced character vector
c(100:130, letters)
#This is a list
list(100:130, letters)

#incomplete commands
5 - 
  
#objects
1:6
a <- 1:6
a

#functions and arguments
round(3.1415) # single argument
?round
round(3.1415, digits = 2) #two arguments, separated by comma

#snake case
#i_use_snake_case

#camel case
#iUseCamelCase

#Why do we use snakes and camels?
pi rounded <- round(3.1415, digits = 2)
pi_rounded <- round(3.1415, digits = 2)


####Challenge 1####
#Start a new script in your personal branch.  It should include a setup block and a code block.  Make it do something in the code block.  
####Section 7: Data import####
#note the path here.  your working directory should be scripts, so your data is up one (..), then down one to data
#The (..) convention means "up one directory" and is a relative path
#contrast the relative path "../data/heights.csv" 
#with the absolute path "/usr/dgauthie/documents/Github/2024_R_seminar/data/heights.csv"

heights <- read_csv("../data/heights.csv")

#reading an individual .xlsx sheet with read_excel
#The "import dataset" wizard in the environment pane is a handy cheat for this.

penguins_Torgerson <- read_excel("../data/penguins.xlsx", 
                                 sheet = "Torgersen Island", #note we don't have to use snake case.  Why?
                                 col_types = c("text", "text", "numeric", "numeric", "numeric", 
                                               "numeric", "text", "numeric"))
View(penguins_Torgerson)

#read in the other sheets in penguins.xlsx

penguins_Biscoe <- read_excel("../data/penguins.xlsx", 
                              sheet = "Biscoe Island", 
                              col_types = c("text", "text", "numeric", "numeric", "numeric", 
                                            "numeric", "text", "numeric"))
View(penguins_Biscoe)

penguins_Dream <- read_excel("../data/penguins.xlsx", 
                             sheet = "Dream Island", 
                             col_types = c("text", "text", "numeric", "numeric", "numeric", 
                                           "numeric", "text", "numeric"))
View(penguins_Dream)

####Challenge 2####
#Working within your own branch, place copies of your own data files in the /data folder.  
#Add a code block that imports these data files into the Rstudio environment.
####Section 19: Joins####

#data frames for joining
#where do these data sets come from?
flights
airlines

#first, lets make flights a little more convenient for viewing
#introducing both the pipe |> and select() here

flights2 <- flights |> 
  select(year, time_hour, origin, dest, tailnum, carrier)
flights2

#these two data sets are going to be joined on the common variable ("key") of <carrier>
#the goal here is to append the flights2 dataframe with the full name of each carrier, based on the abbreviation


#checking whether primary key for the joined table uniquely identifies each record
#functions count() and filter()
#these are tidyverse functions, which we'll get to next week in more detail

airlines |> 
  count(carrier) |> 
  filter(n > 1)

#compare above with the unpiped version:
df <- count(airlines, carrier)
  filter(df, n > 1)

#also should examine your keys for missing values 
airlines |> 
  filter(is.na(carrier))

#left join is the most commonly used form of mutating join.  It is often used to add metadata to a data frame
#again, using <carrier> as key

flights2 |>
  left_join(airlines)

#left join (x,y) keeps all observations in x
#if a row in x has more than one match in y, it will be replicated (see 19.4.1)

airlines |>
  left_join(flights2)

#We could also add weather conditions to the flights dataframe
#what key is used?

flights2 |> 
  left_join(weather |> select(origin, time_hour, temp, wind_speed))

#issues with joining: columns mean different things in the joined tables

flights2 |> 
  left_join(planes)

#solution is to re-specify a key that means the same thing in both tables to be joined

flights2 |> 
  left_join(planes, join_by(tailnum))

#can also join based on keys with different names, provided the same values are present 

flights2 |> 
  left_join(airports, join_by(dest == faa))

#Let's join our three penguins data frames

#this isn't what we want
penguins2 <- left_join(penguins_Biscoe, penguins_Torgerson) |>
  left_join(penguins_Dream)
View(penguins2)

#use rbind instead
penguins3 <- rbind(penguins_Biscoe, penguins_Dream, penguins_Torgerson)
View(penguins3)

#look at NAs in dataframe
penguins3 |>
  filter(if_any(everything(), is.na))

#careful.  There are also "NA" strings in dataframe
penguins3 |>
  filter(if_any(everything(), ~stringr::str_detect(., "NA")))

#let's convert those "NA" strings
penguins4 <- penguins3 |>
  mutate(across(where(is.character), ~na_if(., "NA")))

#Check to see if it worked
penguins4 |>
  filter(if_any(everything(), ~stringr::str_detect(., "NA")))

#This can also be done at the data import step like so: 
penguins_Torgerson <- read_excel("../data/penguins.xlsx", 
                                 sheet = "Torgersen Island", #note we don't have to use snake case.  Why?
                                 col_types = c("text", "text", "numeric", "numeric", "numeric", 
                                               "numeric", "text", "numeric"),
                                 na = "NA") #this has been added
View(penguins_Torgerson)
####

####Challenge 3####
#Using your imported data and your working script, perform some sort of join that merges dataframes.  
#If you only have a single dataframe, practice by splitting it into two or more dfs and re-merging.  



####Section 3: Data Transformation####

flights
?flights

#The first tidyverse row function: filter

#filter operates on ROWS
flights <- flights |> 
  filter(dep_delay > 120)

# Flights that departed on January 1
flights |> 
  filter(month == 1 & month == 1)

# Flights that departed in January or February
df <- flights |> 
  filter(month == 1 | month == 2)

# multiple operations in a pipe
flights |> 
  filter(dep_delay > 120) |>
  filter(month == 1 & day == 1)

# A shorter way to select flights that departed in January or February
flights |> 
  filter(month %in% c(1:10))

#saving to an object
jan1 <- flights |> 
  filter(month == 1 & day == 1)

##Section 3.2.2: Common Mistakes

flights |> 
  filter(month = 1)

flights |> 
  filter(month == 1 | 2)

#3.2.3 our next row function: arrange
#changes order of rows based on column values

var <- flights |> 
  arrange(month, dep_delay)

flights |> 
  arrange(desc(dep_delay))

#3.2.4 distinct

# Remove duplicate rows, if any
flights |> 
  distinct()

# Find all unique origin and destination pairs
flights |> 
  distinct(origin, dest)

flights |>
  filter(origin == "EWR" & dest == "IAH")

#as above, keeping all columns
flights |> 
  distinct(origin, dest, .keep_all = TRUE)

#Section 3.3: Column functions

#mutate (you'll probably use this one more than any other)
new_flights <- flights |> 
  mutate(
    gain = dep_delay - arr_delay, 
    speed = distance / air_time * 60, 
    .after = day
    )

View(new_flights)

flights |> 
  mutate(
    gain = dep_delay - arr_delay,
    speed = distance / air_time * 60,
    .before = 1
  )

flights |> 
  mutate(
    gain = dep_delay - arr_delay,
    speed = distance / air_time * 60,
    .after = day
  )

flights |> 
  mutate(
    gain = dep_delay - arr_delay,
    hours = air_time / 60,
    gain_per_hour = gain / hours,
    .keep = "used"
  )

#select: filters by column instead of row
flights |> 
  select(year, month, day)

flights |> 
  select(year:flight)

flights |> 
  select(!year:day)

flights |> 
  select(where(is.numeric))

#one way to rename a column
#note syntax is select(new_name = old_name)
new_flights <- flights |> 
  select(dep_time, everything())

#rename can also be used for this
new_flights <- flights |> 
  rename(tail_num = tailnum)

#relocate
flights |> 
  relocate(time_hour, air_time)

flights |> 
  relocate(year:dep_time, .after = time_hour)

flights |> 
  relocate(starts_with("arr"), .before = dep_time)

##Section 3.5: group_by() and summarize()

flights |> 
  group_by(month)

flights |> 
  group_by(month) |> 
  summarize(
    avg_delay = mean(dep_delay)
  )

flights |> 
  group_by(month) |> 
  summarize(
    avg_delay = mean(dep_delay, na.rm = TRUE)
  )

flights |> 
  group_by(month) |> 
  summarize(
    avg_delay = mean(dep_delay, na.rm = TRUE), 
    n = n(),
    sd_delay = sd(dep_delay, na.rm = TRUE),
    max_delay = max(dep_delay, na.rm = TRUE),
    min_delay = min(dep_delay, na.rm = TRUE)
  )

#grouping by multiple variables

daily <- flights |>  
  group_by(year, month, day)
daily

daily_flights <- daily |> 
  summarize(n = n())
daily_flights

daily |> 
  filter(!if_any(everything(), is.na)) |>
  summarize(n = n())


####Challenge 4####
#using your working script, perform a data transformation and summary.  You should use mutate(), group_by(), and summarize() functions.
#once you have this working, make it a single piped command.
####Section 12: Summaries and Conditionals####

#any() behaves as | "or" and returns TRUE if any values of x match conditions
#all() behaves as & "and" and returns TRUE if all values of x match conditions.  
flights |> 
  group_by(year, month, day) |> 
  summarize(
    all_delayed = all(dep_delay <= 60, na.rm = TRUE),
    any_long_delay = any(arr_delay >= 300, na.rm = TRUE)
  )

#more useful numerical conditional summaries
#note internal use of mean() and sum()

flights |> 
  group_by(year, month, day) |> 
  summarize(
    proportion_delayed = mean(dep_delay <= 60, na.rm = TRUE),
    count_long_delay = sum(arr_delay >= 300, na.rm = TRUE),
  )

#inline logical filtering with []

flights |> 
  filter(arr_delay > 0) |> 
  group_by(year, month, day) |> 
  summarize(
    behind = mean(arr_delay),
    n = n(),
  )

flights |> 
  group_by(year, month, day) |> 
  summarize(
    behind = mean(arr_delay[arr_delay > 0], na.rm = TRUE),
    ahead = mean(arr_delay[arr_delay < 0], na.rm = TRUE),
    n = n()
  )

#note different behavior of n = n()

#Conditional transformations:  if_else() and case_when()

#if_else() is very similar to Excel's IF function

x <- c(-3:3, NA)
if_else(x > 0, "+ve", "-ve")

if_else(x > 0, "+ve", "-ve", "???")

#nested if_else of above:

if_else(x == 0, "0", if_else(x < 0, "-ve", "+ve"), "???")

#with multiple conditions, if_else gets hard to read.  case_when() is better

x <- c(-3:3, NA)

case_when(
  x == 0   ~ "0",
  x < 0    ~ "-ve", 
  x > 0    ~ "+ve",
  is.na(x) ~ "???"
)

#less explicit specification of non-matching values:

case_when(
  x < 0 ~ "-ve",
  x > 0 ~ "+ve",
  .default = "???"
)

#careful because conditions are evaluated sequentially.  If a value matches, it will not be examined again.

case_when(
  x > 0 ~ "+ve",
  x > 2 ~ "big"
)

#this is when case_when is really useful: piped with mutate()

flights |> 
  mutate(
    status = case_when(
      is.na(arr_delay)      ~ "cancelled",
      arr_delay < -30       ~ "very early",
      arr_delay < -15       ~ "early",
      abs(arr_delay) <= 15  ~ "on time",
      arr_delay < 60        ~ "late",
      arr_delay < Inf       ~ "very late",
    ),
    .keep = "used"
  )



####Challenge 5####
#use case_when() and mutate() together to create a summary of your dataframe
####Section 5: Data tidying and pivoting####

#table 1 is tidy
table1
table1 |>
  mutate(rate = cases / population * 10000)

table1 |> 
  group_by(country) |> 
  summarize(total_cases = sum(cases))

ggplot(table1, aes(x = year, y = cases)) +
  geom_line(aes(group = country), color = "grey50") +
  geom_point(aes(color = country, shape = country)) +
  scale_x_continuous(breaks = c(1999, 2000)) 

#table 2 has variables as values

table2

#what's untidy about table 3?

table3 

#lengthening data 

df <- tribble(
  ~id,  ~bp1, ~bp2,
  "A",  100,  120,
  "B",  140,  115,
  "C",  120,  125
)

df |> 
  pivot_longer(
    cols = bp1:bp2,
    names_to = "measurement",
    values_to = "value"
  )

#making data wider

df <- tribble(
  ~id, ~measurement, ~value,
  "A",        "bp1",    100,
  "B",        "bp1",    140,
  "B",        "bp2",    115, 
  "A",        "bp2",    120,
  "A",        "bp3",    105
)

df |> 
  pivot_wider(
    names_from = measurement,
    values_from = value
  )

####Challenge 6####
#perform pivot_wide() and pivot_long() tranformations of your dataset as necessary to make it completely tidy
####Section 1: Data Visualization with ggplot2####

#different ways to visualize data set
penguins
glimpse(penguins)
View(penguins)
?penguins

##creating a ggplot (see 1.2.2)
#for folks working on the HPC, you will need to select the cairo backend at "Tools" > "Global Options" > "General" > "Graphics" > "Backend"

#empty graph
ggplot(data = penguins)

#map variables to x and y axes
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
)

#add data to the plot with geoms
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point()

#map species to color aesthetic 
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = species)
) +
  geom_point()

#adding a layer (smoothed line)
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = species)
) +
  geom_point() + 
  geom_smooth(method="lm")

#apply the smoothed line to the entire data set, not to individual species
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(mapping = aes(color = species)) +
  geom_smooth(method = "lm")

#map species to both color and shape aesthetics
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(mapping = aes(color = species, shape = species)) +
  geom_smooth(method = "lm")

#Improve labeling of plot
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(aes(color = species, shape = species)) +
  geom_smooth(method = "lm") +
  labs(
    title = "Body mass and flipper length",
    subtitle = "Dimensions for Adelie, Chinstrap, and Gentoo Penguins",
    x = "Flipper length (mm)", y = "Body mass (g)",
    color = "Species", shape = "Species"
  ) +
  scale_color_colorblind()

##Section 1.3

ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point()

#more concise specification

ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) + 
  geom_point()

#with a "pipe"

penguins |> 
  ggplot(aes(x = flipper_length_mm, y = body_mass_g)) + 
  geom_point()

##Section 1.4

#categorical variable and a new geom
ggplot(penguins, aes(x = species)) +
  geom_bar()

#reordered factors
ggplot(penguins, aes(x = fct_infreq(species))) +
  geom_bar()

#numerical variable and geom_histogram
ggplot(penguins, aes(x = body_mass_g)) +
  geom_histogram(binwidth = 200)

ggplot(penguins, aes(x = body_mass_g)) +
  geom_histogram(binwidth = 20)

ggplot(penguins, aes(x = body_mass_g)) +
  geom_histogram(binwidth = 2000)

#geom_density
ggplot(penguins, aes(x = body_mass_g)) +
  geom_density() 

##Section 1.5

#Relationship between numerical and categorical variable with different geoms
ggplot(penguins, aes(x = species, y = body_mass_g)) +
  geom_boxplot()

ggplot(penguins, aes(x = species, y = body_mass_g)) +
  geom_point()

ggplot(penguins, aes(x = body_mass_g, color = species)) +
  geom_density(linewidth = 0.75)

#mapping variable species to both color and fill aesthetics
#setting fill aesthetic to a value (0.5)
ggplot(penguins, aes(x = body_mass_g, color = species, fill = species)) +
  geom_density(alpha = .5)

#stacked barplot
ggplot(penguins, aes(x = island)) +
  geom_bar()

ggplot(penguins, aes(x = island, fill = species)) +
  geom_bar()

#using position argument to change behavior of stacked barplot
ggplot(penguins, aes(x = island, fill = species)) +
  geom_bar(position = "dodge")

#getting complicated.  Three or more variables
#basic plot
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point()
#adding mappings for species and island
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(aes(color = species, shape = island))
#cleaner way to do this with faceting
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(aes(color = species, shape = species)) +
  facet_grid(species ~ island)


####Challenge 7####
#Using your tidied data, create a beautiful plot showing the relationship between a dependent (y) and independent (x) variable, and mapping at least one additional variable.  
####Section 15: Regular Expressions####

#literal matches
str_view(fruit, "berry")

#any character (.)
str_view(fruit, "a...e")

#quantifiers (?, +, *)
str_view(c("a", "ab", "abb"), "ab?")

str_view(c("a", "ab", "abb"), "ab+")

str_view(c("a", "ab", "abb"), "ab*")

#more quantifiers ({})

str_view(c("a", "ab", "abb"), "ab{1}")
str_view(c("a", "ab", "abb"), "ab{2}")

str_view(c("a", "ab", "abb", "aabb", "aaabb", "aaaabb"), "a{2,3}b")

str_view(c("a", "ab", "abb", "aabb", "aaabb", "aaaabb", "ab+"), "ab\\+")

#character classes ([])

str_view(words, "[aeiou]x[aeiou]")

#negated character class ([^])

str_view(words, "[^aeiou]y[^aeiou]")

#alternation (|)
str_view(fruit, "apple|melon|nut")
str_view(fruit, "aa|ee|ii|oo|uu")

str_view(fruit, "o{2,}")

##str_detect
str_detect(c("a", "b", "c"), "[aeiou]")

babynames |> 
  filter(str_detect(name, "x")) |> 
  count(name, wt = n, sort = TRUE)

babynames |> 
  group_by(year) |> 
  summarize(prop_x = mean(str_detect(name, "x"))) |> 
  ggplot(aes(x = year, y = prop_x)) + 
  geom_line()

#escaping
# To create the regular expression \., we need to use \\.
dot <- "\\."

# But the expression itself only contains one \
str_view(dot)


# And this tells R to look for an explicit .
str_view(c("abc", "a.c", "bef"), "a.c")

#anchors
str_view(fruit, "^a")
#> [1] │ <a>pple
#> [2] │ <a>pricot
#> [3] │ <a>vocado
str_view(fruit, "^a.*o$")
#>  [4] │ banan<a>
#> [15] │ cherimoy<a>
#> [30] │ feijo<a>
#> [36] │ guav<a>
#> [56] │ papay<a>
#> [74] │ satsum<a>

#grouping and capturing backreferences
str_view(fruit, "(..)\\1")

str_view(words, "^(..).*\\1$")

#string replace and backreferences

sentences |> 
  str_replace("(\\w+) (\\w+) (\\w+)", "\\1 \\3 \\2") |> 
  str_view()

#finding exact matches

sentences |> 
  str_match("the (\\w+) (\\w+)") |> 
  head()

#non-capturing matches
x <- c("a gray cat", "a grey dog")
str_match(x, "gr(e|a)y")
str_match(x, "gr(?:e|a)y")


#a bit cleaner version with separate_wider_regex
df <- tribble(
  ~str,
  "<Sheryl>-F_34",
  "<Kisha>-F_45", 
  "<Brandon>-N_33",
  "<Sharon>-F_38", 
  "<Penny>-F_58",
  "<Justin>-M_41", 
  "<Patricia>-F_84", 
)
df |> 
  separate_wider_regex(
    str,
    patterns = c(
      "<", 
      name = "[A-Za-z]+", 
      ">-", 
      gender = ".",
      "_",
      age = "[0-9]+"
    )
  )

df2<- str_match(df,"<([A-Za-z]+)>-(.)_([0-9]+)")
df2[,3]

#search scrabble word database

words$word |>
  str_view("")

##give me a challenge...


####Challenge 8####
#Find all words in words$word that have three sets of double letters, e.g. bOOKKEEper or coMMiTTEE

