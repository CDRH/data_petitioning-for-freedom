# Data Repository for Petitioning for Freedom: Habeas Corpus in the Borderlands of Freedom & Slavery  

## About This Data Repository

**How to Use This Repository:** This repository is intended for use with the [CDRH API](https://github.com/CDRH/api) and the [Habeas Corpus Ruby on Rails application](https://github.com/CDRH/habeascorpus).

Issues go on the [Habeas Corpus Rails App Repo](https://github.com/CDRH/habeascorpus)

# Downloading the data

Make sure you have your Airtable API key and the base_id for the spreadsheets. The base_id can be found in the API documentation of the sheet (under Help). Place them in a file `.env`. See the file `sample.env` for a template.
A Python script downloads the Airtable files as JSON and transforms them into CSV files, a format that can be used by Datura. Run this script with `python3 scripts/python/json_to_csv.py`. Then the csv files will be reading for posting with Datura.

# Posting to associate the cases and documents

Make sure the repository includes both the TEI files for documents and the csv of case info
Run `post -f tei` first to post the case documents. This will update the json file associating cases and documents, `source/json/case_documents.json`.
Then run `post -f csv` to post the csv files for cases. Information about associations will be included in the case records.
If you simply run `post` without following this order, the associations for cases may be missing or not up to date.

**Data Repo:** [https://github.com/CDRH/data_habeascorpus](https://github.com/CDRH/data_habeascorpus)

**Source Files:** TEI XML, CSV

**Script Languages:** XSLT, Ruby, JavaScript

**Encoding Schema:** [Text Encoding Initiative (TEI) Guidelines](https://tei-c.org/release/doc/tei-p5-doc/en/html/index.html)

## About Petitioning for Freedom: Habeas Corpus in the Borderlands of Freedom & Slavery  

The Petitioning for Freedom (PFF) project offers humanities and social science scholars access to a database of thousands of unpublished and mostly unindexed habeas petitions from multiple jurisdictions throughout the American West filed between 1812 and 1924. As a dataset, the collection offers a detailed portrait of ordinary peoples' use of the law in the long nineteenth century that allows scholars to consider individual petitions as a collective challenge to inequality and injustice. This database highlights the efforts of marginalized people to right the wrongs that made them subject to others' authority and this study links their petitions to legal reform that has previously been understood as the domain of middle-class reformers, jurists, and politicians. 

The PFF database will be an ideal teaching tool for students interested in the histories of race, gender, family, and the law and is applicable in a broad range of classes in the humanities and social sciences. Users will be able to search the database through a considerable number of categories, making the dataset responsive to a diverse set of research questions. 

Petitions for Freedom: Habeas Corpus in the Borderlands of Freedom & Slavery is a project directed by Katrina Jagodinsky, and published jointly by the Center for Digital Research in the Humanities and the Department of History at the University of Nebraska, Lincoln.

**Project Site:** Site is not live.

**Rails Repo:** [https://github.com/CDRH/habeascorpus](https://github.com/CDRH/habeascorpus)

**Credits:** [https://github.com/CDRH/data_habeascorpus/graphs/contributors](https://github.com/CDRH/data_habeascorpus/graphs/contributors)

**Work to Be Done:** [https://github.com/CDRH/habeascorpus/issues](https://github.com/CDRH/habeascorpus/issues)

## Technical Information

See the [Datura documentation](https://github.com/CDRH/datura) for general updating and posting instructions. 

## About the Center for Digital Research in the Humanities

The Center for Digital Research in the Humanities (CDRH) is a joint initiative of the University of Nebraska-Lincoln Libraries and the College of Arts & Sciences. The Center for Digital Research in the Humanities is a community of researchers collaborating to build digital content and systems in order to generate and express knowledge of the humanities. We mentor emerging voices and advance digital futures for all.

Center for Digital Research in the Humanities GitHub: [https://github.com/CDRH](https://github.com/CDRH)
Center for Digital Research in the Humanities Website: [https://cdrh.unl.edu/](https://cdrh.unl.edu/)
