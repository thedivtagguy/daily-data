import csv
import spacy
import pandas as pd

# import gender guesser
import gender_guesser.detector as gender

d = gender.Detector()
d.get_gender("Bob")
# Read in the csv from a url and store it in a dataframe
df = pd.read_csv('https://raw.githubusercontent.com/thedivtagguy/movie-ratings/master/data/movie_data.csv')

df['genres'] = df['genres'].str.split(',')
out = df.explode('genres')

# Group by genres and select only the role_models_text column
df_grouped = out.groupby('genres')['role_models_text'].apply(list).reset_index()

nlp = spacy.load('en_core_web_sm')

genre_entities = {}

# For each genre, create a list of named entities
for i in range(len(df_grouped)):
    # For each genre, create a list of named entities
    # Add genre to the dictionary
    try:
        genre_entities[df_grouped.iloc[i]['genres']] = []
        for j in range(len(df_grouped.iloc[i]['role_models_text'])):
            doc = nlp(df_grouped.iloc[i]['role_models_text'][j])
            for ent in doc.ents:
                if ent.label_ == 'PERSON':
                    genre_entities[df_grouped.iloc[i]['genres']].append(ent.text)
    except:
        pass

def gender_id(text):
    return d.get_gender(text)

# Iterate through genres in genre_entities and add count
genre_counts = {}
try:
    for key, value in genre_entities.items():
        genre_counts[key] = {}
        male = 0
        female = 0
        for i in value:
            if gender_id(i) == 'male':
                male += 1
            if gender_id(i) == 'female':
                female += 1
        genre_counts[key] = {'male': male, 'female': female}
except:
    pass            

# Save dictionary to df
gender_counts = pd.DataFrame(genre_counts)

gender_counts.to_csv("genre_gender_counts.csv")