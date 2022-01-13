# get Pandas and filesystem related modules
import pandas as pd
from pathlib import Path
cwd = Path.cwd()
# download the spreadsheets and give them the proper names? to do later
# Get all the spreadsheets' file paths
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
# create dataframes for each of the spreadsheets, and clean them up
cases_frame = pd.read_json(cases_path, orient="records")
blank_rows = cases_frame["Case ID"].isna()
cases_frame = cases_frame[~blank_rows]
locations_frame = pd.read_json(locations_path, orient="records")
# replace the locations key with the (merged) columns from locations sheet
cases_frame["Location"] = cases_frame["Location"].str[0]
locations_frame = locations_frame.rename(columns={"airtable_id": "Location", "Name": "Location name", "city": "Location city", "county": "Location county", "state/territory": "Location state"})
cases_frame = cases_frame.merge(locations_frame[["Location", "Location name", "Location city", "Location county", "Location state"]], how = "left", on = "Location")
cases_frame = cases_frame.drop(columns=["Location"])
# do the same for people and all its join models
# make sure the arrays, as of people, are delimited by semicolons
# write the cases frame to csv
cases_frame.to_csv("source/csv/habeas_airtable.csv")
