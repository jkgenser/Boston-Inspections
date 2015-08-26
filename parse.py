import os, pandas as pd

df = pd.read_csv("Food_Establishment_Inspections.csv")

# Of all violation status, how many are each type?
# df.groupby(['ViolStatus']).size()
""" ViolStatus
                 844
Fail          171808
Pass          139086 """

# Drop blanks and Pass
df = df[df['ViolStatus'] == 'Fail']

# Drop unnecessary columns
map(lambda x: df.pop(x), ['DESCRIPT', 'StatusDate', 'RESULT', 'LICENSENO', 'ISSDTTM', 'EXPDTTM', 'LICENSECAT'])

# Check for 'RESULTDTTM' or 'Location' blank
# pd.isnull(df['RESULTDTTM']).any() """ FALSE """
# pd.isnull(df['Location']).any() """ TRUE """

# How many results have blank 'Location'?
# df['Location'].isnull().sum() """ 52,800 """

# Drop if Location is blank
df = df[pd.notnull(df['Location'])] # 119,008 results remain

# Separate latitude and longitude field into two columns
df['Latitude'] = df['Location'].apply(lambda x: x.split(',')[0][1:] ) # drop the first parenthesis
df['Longitude'] = df['Location'].apply(lambda x: x.split(',')[1][:-1] ) # drop the last parenthesis
df.pop('Location')

# Output to .csv file
df.to_csv("food_inspections.csv")
