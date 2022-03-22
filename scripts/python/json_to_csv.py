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
command = f"bin/airtable-export source/json {AIRTABLE_BASE_ID} Cases People 'Case Data [join]' 'Relationships [join]' Locations --key={API_KEY} --json"
os.system(command)
# Get all the spreadsheets' file paths
cases_relative = "source/json/cases.json"
# case_role_relative = "source/json/case role [join].json"
# locations_relative = "source/json/locations.json"
people_relative = "source/json/people.json"
# relationships_relative = "source/json/relationships [join].json"
cases_path = (cwd / cases_relative).resolve()
# case_role_path = (cwd / case_role_relative).resolve()
# locations_path = (cwd / locations_relative).resolve()
people_path = (cwd / people_relative).resolve()
# relationships_path = (cwd / relationships_relative).resolve()
# create dataframes for each of the spreadsheets
cases_frame = pd.read_json(cases_path, orient="records")
# locations_frame = pd.read_json(locations_path, orient="records")
people_frame = pd.read_json(people_path, orient="records")
# case_role_frame = pd.read_json(case_role_path, orient="records")
# relationships_frame = pd.read_json(relationships_path, orient="records")
# clean frames of blank entries

# change "[id]" to "id"
cases_frame["Location of Court"] = cases_frame["Location of Court"].str[0]
# case_role_frame["Case"] = case_role_frame["Case"].str[0]
# case_role_frame["Person"] = case_role_frame["Person"].str[0]
# relationships_frame["person 1"] = relationships_frame["person 1"].str[0]
# relationships_frame["Cases"] = relationships_frame["Cases"].str[0]
# set indices so values can be retrieved in the proper order
# group_by to combine persons with multiple roles and relationships (group_by also has the effect of setting the index)
# case_role_frame = case_role_frame.groupby(["Person", "Case"]).agg({"Case Role": pd.Series.to_list})
# case_role_frame["Case Role"] = case_role_frame["Case Role"].astype(str)
people_frame = people_frame.set_index("airtable_id")
# relationships_frame = relationships_frame.groupby(["person 1", "Cases"]).agg({"relationship type": pd.Series.to_list, "person 2": pd.Series.to_list})
# relationships_frame["relationship type"] = relationships_frame["relationship type"].astype(str)
# change locations column names to desired values (especially important: make sure join column has the same name)
# locations_frame = locations_frame.rename(columns={"airtable_id": "Location", "Name": "Location name", "city": "Location city", "county": "Location county", "state/territory": "Location state"})
# merge the frames, this is similar to a SQL join; specify the column names needed
# cases_frame = cases_frame.merge(locations_frame[["Location", "Location name", "Location city", "Location county", "Location state"]], how = "left", on = "Location")
# columns to take from the people array
desired_fields = ["Age Category", "Date of Birth", "Participants", "Immigrant Status", "Race or Ethnicity", "Sex", "Tags", "Notes"]
# go through all these fields and fill them in
# for field in desired_fields:
#     # make sure the arrays are delimited by semicolons
#     people_frame[field] = people_frame[field].astype(str)
#     # find matching people, or leave blank if there are no associated people (person_list will be NaN in that case)
#     cases_frame["Person " + field] = ["; ".join(people_frame.loc[person_list][field]) if isinstance(person_list, list) else "" for person_list in cases_frame["People"]]
# make a list of all the people for each case, with corresponding case_id
# people_cases = zip(cases_frame["People"], cases_frame["airtable_id"])
# fills in case roles from sheets
# go through all the cases and the corresponding people
# for person_list, case_airtable_id in people_cases:
#     case_roles_list = []
#     relationship_list = []
#     person_2_list = []
#     # check if person_list exists (if not it will be NaN)
#     if isinstance(person_list, list):
#         # go through all the individual people
#         for person in person_list:
#             # make sure there is a corresponding entry/entries in case roles
#             if (person, case_airtable_id) in case_role_frame.index:
#                 case_role = case_role_frame.loc[(person, case_airtable_id)]["Case Role"]
#                 case_roles_list.append(case_role)
#             else:
#                 case_roles_list.append("")
#             # same for relationships, either find the corresponding entry or insert a blank
#             if (person, case_airtable_id) in relationships_frame.index:
#                 # find relationships and corresponding people
#                 relationship = relationships_frame.loc[(person, case_airtable_id)]["relationship type"]
#                 person_2_ids = relationships_frame.loc[(person, case_airtable_id)]["person 2"]
#                 # look up names in people table
#                 person_2_names = str([people_frame.loc[id]["Participants"].values[0] for id in person_2_ids])
#                 # fill in lists of relationships and relatees
#                 relationship_list.append(relationship)
#                 person_2_list.append(person_2_names)
#             # otherwise record relationships as blank
#             else:
#                 relationship_list.append("")
#                 person_2_list.append("")
#     # fill in the case roles, relationship and relatees fields in case frame
#     cases_frame.loc[cases_frame["airtable_id"] == case_airtable_id, "Person Case Roles"] = "; ".join(case_roles_list)
#     cases_frame.loc[cases_frame["airtable_id"] == case_airtable_id, "Person Relationships"] = "; ".join(relationship_list)
#     cases_frame.loc[cases_frame["airtable_id"] == case_airtable_id, "Person Relatees"] = "; ".join(person_2_list)

# remove unwanted columns, join ids, airtable-specific metadata, etc. and rename desired columns
cases_frame = cases_frame.drop(columns=["Case Role [join]", "Encoding Notes", "Last Modified", "Location of Court", "People", "Primary field", "airtable_createdTime", "airtable_id", "Relationships [join]", "Created", "Encoding Incomplete?"])
cases_frame = cases_frame.rename(columns={"Additional Parties Named in Document: Last, First": "Additional Parties", "Record Type(s)": "Record Type"})
people_frame = people_frame.drop(columns=["Created", "Last Modified", "airtable_createdTime", "auto_gen_id", "Encoding Notes", "Relationships [join]", "Relationships [join] 2"])
for label in ["Petition Type", "Record Type", "Repository", "Site(s) of Significance", "Tags"]:
    cases_frame[label] = cases_frame[label].apply(json.dumps)
for label in ["Birth Place", "Indicated Age Category (from Case Data [join])", "Race or Ethnicity", "Sex", "Tags"]:
    people_frame[label] = people_frame[label].apply(json.dumps)
cases_frame = cases_frame.fillna('')
cases_frame = cases_frame.replace('NaN', '')
people_frame = people_frame.fillna('')
people_frame = people_frame.replace('NaN', '')
# write the cases frame to csv
cases_frame.to_csv("source/csv/habeas_airtable_cases.csv")
people_frame.to_csv("source/csv/habeas_airtable_people.csv")
