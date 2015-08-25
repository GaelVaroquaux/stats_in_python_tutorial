"""
Exploring diabetes hospital readmission
=================================================

"""

import pandas
import numpy as np

data = pandas.read_csv('../dataset_diabetes/diabetic_data.csv', na_values='?')

# Age and weights are given as ranges, that are interpreted as string
for key in ('age', 'weight'):
    for string_value in data[key].dropna().unique():
        numerical_values = string_value[1:-1].split('-')
        numerical_value = np.mean([float(v) for v in numerical_values])
        data[key] = data[key].replace(string_value, numerical_value)


from pandas.tools import plotting

# Scatter matrices for different columns
plotting.scatter_matrix(data[['age', 'weight', 'time_in_hospital',
       'max_glu_serum', 'A1Cresult', 'metformin',
       'repaglinide', 'nateglinide', 'chlorpropamide', 'glimepiride',
       'acetohexamide', 'glipizide', 'glyburide', 'tolbutamide',
       'pioglitazone', 'rosiglitazone', 'acarbose', 'miglitol',
       'troglitazone', 'tolazamide', 'citoglipton', 'insulin',
       'glyburide-metformin', 'glipizide-metformin',
       'glimepiride-pioglitazone', 'metformin-rosiglitazone',
       'metformin-pioglitazone']])
#plotting.scatter_matrix(data[['PIQ', 'VIQ', 'FSIQ']])

import matplotlib.pyplot as plt
plt.show()
