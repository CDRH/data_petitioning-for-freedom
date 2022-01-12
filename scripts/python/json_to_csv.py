# get Pandas and filesystem related modules
import pandas as pd
from pathlib import Path
cwd = Path.cwd()
# download the spreadsheets and give them the proper names? to do later
# Get all the spreadsheets as paths
cases_relative = "source/airtable/cases.json"
case_role_relative = "source/airtable/case role [join].json"
locations_relative = "source/airtable/locations.json"
people_relative = "source/airtable/people.json"
relationships_relative = "source/airtable/relationships [join].json"
cases_path = (cwd / cases_relative).resolve()
case_role_path = (cwd / case_role_relative).resolve()
locations_path = (cwd / locations_relative).resolve()
people_path = (cwd / people_relative).resolve()
relationships_path = (cwd / relationships_relative).resolve()
# Create a dataframe from the Cases one
with open(cases_path, 'r') as f:
    print(f.read())
cases_frame = pd.read_json(cases_path, orient="records")
# add the necessary rows from the other tables--replace the ids with data
# make sure the arrays, as of people, are delimited by semicolons
# write to csv
cases_frame.to_csv("source/csv/habeas_airtable.csv")
