import string
import pandas as pd


# Read in pi text file 
text = ""
# Initialize an empty dataframe
colors = [
    '#0B0033',
    '#376996',
    '#C3B299',
    '#815355',
    '#C09BD8',
    '#48284A',
    '#916C80',
    '#3B1F2B',
    '#DB162F',
    '#5F758E'
]

df = pd.DataFrame()
# Create new column in dataframe
df['digit'] = ""
df['color'] = ""
with open('pi.txt') as f:
    while True:
        c = f.read(1)
        if not c:
            print("Empty file")
            break
        else:
            # If it is a number, add it to the dataframe
            if c in string.digits:
                this_row = [c, colors[int(c)]]
                df.loc[len(df)] = this_row
                print(c + " added to the dataframe")
            else:
                this_row = [".", "#000000"]
                df.loc[len(df)] = this_row

# Write the dataframe to a csv file
df.to_csv('pi.csv', index=False)