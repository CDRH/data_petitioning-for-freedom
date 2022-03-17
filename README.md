# Habeas Corpus

Project under development

Intended for use with the [CDRH Datura Gem](https://github.com/CDRH/datura).

Issues go on the [Habeas Corpus Rails App Repo](https://github.com/CDRH/habeascorpus)

# Posting to associate the cases and documents

Make sure the repository includes both the TEI files for documents and the csv of case info
Run `post -f tei` first to post the case documents. This will update the json file associating cases and documents, `source/json/case_documents.json`.
Then run `post -f csv` to post the csv files for cases. Information about associations will be included in the case records.
If you simply run `post` without following this order, the associations for cases may be missing or not up to date.
