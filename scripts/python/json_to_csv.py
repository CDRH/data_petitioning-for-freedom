# get Pandas and filesystem related modules
import pandas as pd
from pathlib import Path
import os
from dotenv import load_dotenv, find_dotenv
import json

load_dotenv(find_dotenv())

AIRTABLE_BASE_ID = os.environ.get("AIRTABLE_BASE_ID")
API_KEY = os.environ.get("API_KEY")
cwd = Path.cwd()
# download the spreadsheets from command line using airtable_export
command = f"bin/airtable-export source/json {AIRTABLE_BASE_ID} Cases People --key={API_KEY} --json"
os.system(command)
# Get all the spreadsheets' file paths
cases_relative = "source/json/cases.json"
people_relative = "source/json/people.json"
cases_path = (cwd / cases_relative).resolve()
people_path = (cwd / people_relative).resolve()
# create dataframes for each of the spreadsheets
cases_frame = pd.read_json(cases_path, orient="records")
people_frame = pd.read_json(people_path, orient="records")
# set index so values can be retrieved in the proper order
people_frame = people_frame.set_index("airtable_id")
# remove unwanted columns, join ids, airtable-specific metadata, etc. and rename desired columns
cases_frame = cases_frame.drop(columns=["Encoding Notes", "Last Modified", "Last Modified By", "People", "airtable_createdTime", "airtable_id", "Created", "Created By", "Encoding Incomplete?", "Relationships [join]", "Case Role [join]", "Petition Outcome Old"])
people_frame = people_frame.drop(columns=["Created", "Created By", "Last Modified", "Last Modified By", "airtable_createdTime", "auto_gen_id", "Encoding Notes", "Relationships [join]", "Relationships [join] 2", "Case Role [join]"])
# make sure what is being written to CSV is proper JSON
for label in ["Petition Type", "Document Type(s)", "Repository", "Site(s) of Significance", "Tags", "Petitioners", "RDF - person role case (from Case Role [join])", "Court Location(s)", "Petition Outcome", "Fate of Bound Party(s)", "Court Type(s)", "Court Name(s)", "Record Type(s)", "bound_party_age", "bound_party_race", "bound_party_sex"]:
    cases_frame[label] = cases_frame[label].apply(json.dumps)
for label in ["Birth Place", "Indicated Age Category (from Case Data [join])", "Race or Ethnicity", "Sex", "Tags", "RDF - person role case (from Case Role [join])", "RDF - person relationship person (from Relationships [join])", "RDF - person relationship person (from Relationships [join] 2)", "Cases Text", "person_case_year"]:
    people_frame[label] = people_frame[label].apply(json.dumps)
# replace bad values
cases_frame = cases_frame.fillna('')
cases_frame = cases_frame.replace('NaN', '')
people_frame = people_frame.fillna('')
people_frame = people_frame.replace('NaN', '')
# write the cases frame to csv
cases_frame.to_csv("source/csv/habeas_airtable_cases.csv")
people_frame.to_csv("source/csv/habeas_airtable_people.csv")
