# get Pandas and filesystem related modules
import pandas as pd
from pathlib import Path
cwd = Path.cwd()
# TODO download the spreadsheets from command line using airtable_export
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
# create dataframes for each of the spreadsheets
cases_frame = pd.read_json(cases_path, orient="records")
locations_frame = pd.read_json(locations_path, orient="records")
people_frame = pd.read_json(people_path, orient="records")
case_role_frame = pd.read_json(case_role_path, orient="records")
relationships_frame = pd.read_json(relationships_path, orient="records")
# clean frames of blank entries
blank_rows = cases_frame["Case ID"].isna()
cases_frame = cases_frame[~blank_rows]
people_frame = people_frame.fillna("")
# change "[id]" to "id"
cases_frame["Location"] = cases_frame["Location"].str[0]
case_role_frame["Case"] = case_role_frame["Case"].str[0]
case_role_frame["Person"] = case_role_frame["Person"].str[0]
#set indices so values can be retrieved in the proper order
people_frame = people_frame.set_index("airtable_id")
case_role_frame = case_role_frame.set_index(["Person", "Case"])
# change locations column names to desired values (especially important: make sure join column has the same name)
locations_frame = locations_frame.rename(columns={"airtable_id": "Location", "Name": "Location name", "city": "Location city", "county": "Location county", "state/territory": "Location state"})
# merge the frames, this is similar to a SQL join; specify the column names needed
cases_frame = cases_frame.merge(locations_frame[["Location", "Location name", "Location city", "Location county", "Location state"]], how = "left", on = "Location")
# convert array fields into strings
people_frame["Race or Ethnicity"] = people_frame["Race or Ethnicity"].astype(str)
people_frame["Tags"] = people_frame["Tags"].astype(str)
# columns to take from the people array
desired_fields = ["Age Category", "Date of Birth", "Participants", "Immigrant Status", "Race or Ethnicity", "Sex", "Tags", "Notes"]
# finds the matching people, given a list of person ids.
matching_people = lambda person_list: people_frame.loc[person_list]
for field in desired_fields:
    # fills in the given fields, and makes sure the arrays are delimited by semicolons
    cases_frame["Person " + field] = ["; ".join(matching_people(person_list)[field]) for person_list in cases_frame["People"]]
# finds the matching case roles, given a list of person ids AND the case (airtable) id.
# Note I am NOT using the case_role column because it doesn't match up the data by people the way I want
matching_case_roles = lambda person_list, case_airtable_id: case_role_frame.loc[[(person, case_airtable_id) for person in person_list]]
# fills in case roles from sheets TODO: make sure case roles are grouped by people
cases_frame["Person Case Role"] = ["; ".join(matching_case_roles(person_list, case_airtable_id)["Case Role"]) for person_list, case_airtable_id in zip(cases_frame["People"], cases_frame["airtable_id"])]
# TODO: remove unwanted columns, join ids, airtable-specific metadata, etc.
cases_frame = cases_frame.drop(columns=["Location", "People"])
# write the cases frame to csv
cases_frame.to_csv("source/csv/habeas_airtable.csv")
