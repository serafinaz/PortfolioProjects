import pandas as pd
import seaborn as sns
import matplotlib
import numpy as np
import matplotlib.pyplot as plt
plt.style.use('ggplot')
from matplotlib.pyplot import figure

#read in the data
df = pd.read_csv(r'/Users/shafanzheng/Downloads/DAProject/movies.csv')

#take a look at the data
#print(df.head())

# We need to see if we have any missing data
# Let's loop through the data and see if there is anything missing
for col in df.columns:
    pct_missing = np.mean(df[col].isnull())
    print('{} - {}%'.format(col, round(pct_missing*100)))

# Data Types for our columns
print(df.dtypes)

#change dt for our columns
#df['budget'] = df['budget'].astype('int64')
#df['gross'] = df['gross'].astype('int64')

# creat correct year column
df['correctyear'] = df['released'].astype(str).str[-20:-16] # -20: -16 means the year in the str, which is like 2019
df.sort_values(by=['gross'],inplace=False, ascending=False)

print(df.head())
pd.set_option('display.max_rows', None)

#drop any duplicate
df['company'].drop_duplicates().sort_values(ascending=False)

#budget with high correlation
#company high correlation

#build a scatter plot with score vs gross
#plt.scatter(x = df['score'], y = ['gross']) # xy have different sizes.
#plt.title('score vs gross earning')
#plt.xlabel('Gross Earnings')
#plt.ylabel('Score for film')
#plt.show()

#plot the budget vs gross useing seaborn
sns.regplot(x= 'score', y= 'gross', data=df, scatter_kws={'color': 'red'},line_kws={'color': 'blue'})
plt.show()
#Looking at correlation
df2 = df.iloc[0:7669,11:13]
correlation_matrix = df2.corr(method='pearson') #pearson, kendall, spearman
sns.heatmap(correlation_matrix, annot=True)
plt.title('Correlation matrix for numeric Features')
plt.xlabel('Movie Features')
plt.ylabel('Movie Features')
plt.show()

#look at company
df_numerized = df
for col_name in df_numerized.columns:
    if(df_numerized[col_name].dtype == 'object'):
        df_numerized[col_name] = df_numerized[col_name].astype('category')
        df_numerized[col_name] = df_numerized[col_name].cat.codes

correlation_mat = df_numerized.corr()
corr_pairs = correlation_mat.unstack()
corr_pairs
sorted_pairs = corr_pairs.sort_values()
high_corr = sorted_pairs[(sorted_pairs) > 0.5]