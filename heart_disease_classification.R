# ==============================================================================
# Project: Heart Disease Risk Prediction & Patient Clustering
# Author: Ally Herleth
# Date: August 2026
# Description: Preprocesses and deduplicates clinical patient records (n = 302),
#              performs exploratory visualization, and evaluates C5.0 Decision Tree,
#              Naive Bayes, and K-Means clustering models for heart disease risk.
# Required Packages: ggplot2, corrplot, C50, e1071
# ==============================================================================

library(ggplot2)
library(corrplot)
library(C50)
library(e1071)

##### Preprocessing step 1 #####
# Load data from GitHub repo 'data/' folder (or fallback to root folder)
heart <- if (file.exists("data/heart.csv")) read.csv("data/heart.csv") else read.csv("heart.csv")

# Check structure before converting
str(heart)

# Convert categorical variables to factors
heart$sex <- factor(heart$sex, levels = c(0,1), labels = c("Female","Male"))
heart$cp <- factor(heart$cp, levels = c(0,1,2,3))
heart$fbs <- factor(heart$fbs, levels = c(0,1), labels = c("No","Yes"))
heart$restecg <- factor(heart$restecg, levels = c(0,1,2))
heart$exang <- factor(heart$exang, levels = c(0,1), labels = c("No","Yes"))
heart$slope <- factor(heart$slope, levels = c(0,1,2))
heart$ca <- factor(heart$ca, levels = c(0,1,2,3,4))
heart$thal <- factor(heart$thal, levels = c(0,1,2,3))
heart$target <- factor(heart$target, levels = c(0,1), labels = c("No Disease","Disease"))

# Check structure after converting
str(heart)

# Confirm no missing values
sum(is.na(heart))

##### De-duplicate #####
heart_unique <- heart[!duplicated(heart), ]
nrow(heart_unique)

##### Train-Test Split (75/25) #####
# Set seed for reproducibility
set.seed(123)

# Train/test split (75/25)
sample_size <- floor(0.75 * nrow(heart_unique))
train_index <- sample(seq_len(nrow(heart_unique)), size = sample_size)

train <- heart_unique[train_index, ]
test <- heart_unique[-train_index, ]

# Confirm split sizes
nrow(train)
nrow(test)

##### EDA Plot 1: Age distribution by target #####
ggplot(heart_unique, aes(x = age, fill = target)) +
  geom_histogram(position = "identity", alpha = 0.6, bins = 20) +
  labs(x = "Age", y = "Count", fill = "Diagnosis",
       title = "Age Distribution by Heart Disease Status") +
  theme_minimal()

##### EDA Plot 2: Cholesterol and Max Heart Rate by target #####
ggplot(heart_unique, aes(x = target, y = chol, fill = target)) +
  geom_boxplot() +
  labs(x = "Diagnosis", y = "Cholesterol", title = "Cholesterol by Heart Disease Status") +
  theme_minimal()

ggplot(heart_unique, aes(x = target, y = thalach, fill = target)) +
  geom_boxplot() +
  labs(x = "Diagnosis", y = "Max Heart Rate", title = "Max Heart Rate by Heart Disease Status") +
  theme_minimal()

##### EDA Plot 3: Chest pain type by target #####
ggplot(heart_unique, aes(x = cp, fill = target)) +
  geom_bar(position = "dodge") +
  labs(x = "Chest Pain Type", y = "Count", fill = "Diagnosis",
       title = "Chest Pain Type by Heart Disease Status") +
  theme_minimal()

##### EDA Plot 4: Correlation matrix #####
numeric_vars <- heart_unique[, c("age","trestbps","chol","thalach","oldpeak")]
cor_matrix <- cor(numeric_vars)
print(cor_matrix)

corrplot(cor_matrix, method = "color", addCoef.col = "black", 
         type = "upper", tl.col = "black")

##### Decision Tree Model #####
predictors <- c("age","sex","cp","trestbps","chol","fbs","restecg",
                "thalach","exang","oldpeak","slope","ca","thal")

dt_model <- C5.0(x = train[, predictors], y = train$target)

summary(dt_model)
plot(dt_model)

##### Decision Tree accuracy on test data #####
dt_pred <- predict(dt_model, newdata = test)

evaluation <- cbind(test, dt_pred)
evaluation$correct <- ifelse(evaluation$target == evaluation$dt_pred, 1, 0)

# Accuracy
sum(evaluation$correct) / nrow(evaluation)

# TPR (Sensitivity) - correctly predicted Disease cases
TPR <- sum(evaluation$dt_pred == 'Disease' & evaluation$target == 'Disease') / sum(evaluation$target == 'Disease')
TPR

# TNR (Specificity) - correctly predicted No Disease cases
TNR <- sum(evaluation$dt_pred == 'No Disease' & evaluation$target == 'No Disease') / sum(evaluation$target == 'No Disease')
TNR

FPR <- 1 - TNR
FNR <- 1 - TPR

# Precision
dt_precision <- sum(evaluation$target == 'Disease' & evaluation$dt_pred == 'Disease') / sum(evaluation$dt_pred == 'Disease')
dt_precision

# F1
dt_F1 <- 2 * dt_precision * TPR / (dt_precision + TPR)
dt_F1

##### Naive Bayes Model #####
nb_model <- naiveBayes(x = train[, predictors], y = train$target)

nb_model

##### Naive Bayes accuracy on test data #####
nb_pred <- predict(nb_model, newdata = test)

evaluation_nb <- cbind(test, nb_pred)
evaluation_nb$correct <- ifelse(evaluation_nb$target == evaluation_nb$nb_pred, 1, 0)

# Accuracy
sum(evaluation_nb$correct) / nrow(evaluation_nb)

# TPR (Sensitivity)
nb_TPR <- sum(evaluation_nb$nb_pred == 'Disease' & evaluation_nb$target == 'Disease') / sum(evaluation_nb$target == 'Disease')
nb_TPR

# TNR (Specificity)
nb_TNR <- sum(evaluation_nb$nb_pred == 'No Disease' & evaluation_nb$target == 'No Disease') / sum(evaluation_nb$target == 'No Disease')
nb_TNR

nb_FPR <- 1 - nb_TNR
nb_FNR <- 1 - nb_TPR

# Precision
nb_precision <- sum(evaluation_nb$target == 'Disease' & evaluation_nb$nb_pred == 'Disease') / sum(evaluation_nb$nb_pred == 'Disease')
nb_precision

# F1
nb_F1 <- 2 * nb_precision * nb_TPR / (nb_precision + nb_TPR)
nb_F1

##### K-Means Clustering #####
# Select and scale numeric variables
cluster_vars <- heart_unique[, c("age","trestbps","chol","thalach","oldpeak")]
cluster_vars_scaled <- scale(cluster_vars)

# Check how many clusters make sense (elbow method)
set.seed(123)
wss <- sapply(1:10, function(k){
  kmeans(cluster_vars_scaled, centers = k, nstart = 25)$tot.withinss
})

plot(1:10, wss, type = "b", pch = 19,
     xlab = "Number of Clusters (k)", ylab = "Total Within-Cluster Sum of Squares",
     main = "Elbow Method for Choosing k")

##### Run K-Means with k=3 #####
set.seed(123)
km_model <- kmeans(cluster_vars_scaled, centers = 3, nstart = 25)

# Cluster sizes
km_model$size

# Cluster centers (in scaled units)
km_model$centers

# Add cluster assignment back to the original data for interpretation
heart_unique$cluster <- as.factor(km_model$cluster)

# Compare cluster profiles using original (unscaled) values
aggregate(cluster_vars, by = list(Cluster = heart_unique$cluster), FUN = mean)

# Check how clusters relate to actual disease status
table(heart_unique$cluster, heart_unique$target)

##### Descriptive Statistics on final dataset #####
summary(heart_unique[, c("age","sex","cp","trestbps","chol","fbs","restecg",
                         "thalach","exang","oldpeak","slope","ca","thal","target")])

sapply(heart_unique[, c("age","trestbps","chol","thalach","oldpeak")], sd)