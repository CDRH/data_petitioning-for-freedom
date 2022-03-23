# Habeas Corpus

Project under development

Intended for use with the [CDRH Datura Gem](https://github.com/CDRH/datura).

Issues go on the [Habeas Corpus Rails App Repo](https://github.com/CDRH/habeascorpus)

# Downloading the data

Make sure you have your Airtable API key and the base_id for the spreadsheets. The base_id can be found in the API documentation of the sheet (under Help). Place them in a file `.env`. See the file `sample.env` for a template.
A Python script downloads the Airtable files as JSON and transforms them into CSV files, a format that can be used by Datura. Run this script with `python3 scripts/python/json_to_csv.py`. Then the csv files will be reading for posting with Datura.

# Posting to associate the cases and documents

Make sure the repository includes both the TEI files for documents and the csv of case info
Run `post -f tei` first to post the case documents. This will update the json file associating cases and documents, `source/json/case_documents.json`.
Then run `post -f csv` to post the csv files for cases. Information about associations will be included in the case records.
If you simply run `post` without following this order, the associations for cases may be missing or not up to date.
