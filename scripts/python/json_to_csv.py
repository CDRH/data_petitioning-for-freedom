# get Pandas and filesystem related modules
import pandas as pd
from pathlib import Path
import os
from dotenv import load_dotenv
load_dotenv()
env_path = Path('.')/'.env'
load_dotenv(dotenv_path=env_path)
import json
from helpers import remove_quotes

AIRTABLE_BASE_ID = os.getenv("AIRTABLE_BASE_ID")
API_KEY = os.getenv("API_KEY")
cwd = Path.cwd()
# download the spreadsheets from command line using airtable_export
command = f"airtable-export source/json {AIRTABLE_BASE_ID} Cases People Locations --key={API_KEY} --json"
os.system(command)
# Get all the spreadsheets' file paths
cases_relative = "source/json/cases.json"
people_relative = "source/json/people.json"
locations_relative = "source/json/locations.json"
cases_path = (cwd / cases_relative).resolve()
people_path = (cwd / people_relative).resolve()
locations_path = (cwd / locations_relative).resolve()
# create dataframes for each of the spreadsheets
cases_frame = pd.read_json(cases_path, orient="records")
people_frame = pd.read_json(people_path, orient="records")
locations_frame = pd.read_json(locations_path, orient="records")
# set index so values can be retrieved in the proper order
people_frame = people_frame.set_index("airtable_id")
# remove unwanted columns, join ids, airtable-specific metadata, etc. and rename desired columns
cases_frame = cases_frame.drop(columns=["Encoding Notes", "Last Modified", "Last Modified By", "People", "airtable_createdTime", "airtable_id", "Created", "Created By", "Encoding Incomplete?", "Relationships [join]", "Case Role [join]", "Petition Outcome Old", "Court Location(s) (OLD)", "Court Type(s) (OLD)"])
people_frame = people_frame.drop(columns=["Created", "Created By", "Last Modified", "Last Modified By", "airtable_createdTime", "auto_gen_id", "Encoding Notes", "Relationships [join]", "Relationships [join] 2", "Case Role [join]", "RDF - person role case (from Case Role [join])"])
# remove "" characters from within arrays, airtable creates them but they are unneeded
people_frame = remove_quotes(people_frame, 'RDF - person relationship person (from Relationships [join])')
people_frame = remove_quotes(people_frame, 'RDF - person relationship person (from Relationships [join] 2)')
people_frame = remove_quotes(people_frame, 'case_role')
people_frame = remove_quotes(people_frame, 'person_age')
people_frame = remove_quotes(people_frame, 'person_case_year')
people_frame = remove_quotes(people_frame, 'person_nationality')
people_frame = remove_quotes(people_frame, 'person_notes')
people_frame = remove_quotes(people_frame, 'person_race')
people_frame = remove_quotes(people_frame, 'person_sex')
people_frame = remove_quotes(people_frame, 'person_tags')
cases_frame = remove_quotes(cases_frame, "Petitioners")
cases_frame = remove_quotes(cases_frame, "RDF - person role case (from Case Role [join])")
cases_frame = remove_quotes(cases_frame, "bound_party_age")
cases_frame = remove_quotes(cases_frame, "bound_party_sex")
cases_frame = remove_quotes(cases_frame, "bound_party_race")
cases_frame = remove_quotes(cases_frame, "petitioner_age")
cases_frame = remove_quotes(cases_frame, "petitioner_race")
cases_frame = remove_quotes(cases_frame, "petitioner_sex")
# these methods sometimes result in nan values, replace with empty strings
cases_frame = cases_frame.fillna('')
cases_frame = cases_frame.replace('NaN', '')
people_frame = people_frame.fillna('')
people_frame = people_frame.replace('NaN', '')
for label in ["Petition Type", "Site(s) of Significance", "Tags", "Petitioners", "RDF - person role case (from Case Role [join])", "Petition Outcome", "Fate of Bound Party(s)", "Court Name(s)", "Source Material(s)", "bound_party_age", "bound_party_race", "bound_party_sex", "Repository"]:
    cases_frame[label] = cases_frame[label].apply(json.dumps)
for label in ["Birth Place", "Indicated Age Category (from Case Data [join])", "Race or Ethnicity", "Sex", "Tags", "RDF - person relationship person (from Relationships [join])", "RDF - person relationship person (from Relationships [join] 2)", "Cases Text", "person_case_year", "person_nationality", "case_role", "person_sex", "person_age", "person_race", "person_notes", "person_tags"]:
    people_frame[label] = people_frame[label].apply(json.dumps)
locations_frame["location subtype"] = locations_frame["location subtype"].apply(json.dumps)
# replace bad values
cases_frame = cases_frame.fillna('')
cases_frame = cases_frame.replace('NaN', '')
people_frame = people_frame.fillna('')
people_frame = people_frame.replace('NaN', '')
# write the cases frame to csv
cases_frame.to_csv("source/csv/habeas_airtable_cases.csv")
people_frame.to_csv("source/csv/habeas_airtable_people.csv")
locations_frame.to_csv("source/csv/habeas_airtable_locations.csv")
