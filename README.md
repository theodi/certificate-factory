# Certificate Factory

Automagically generate [Open Data Certificates](https://certificates.theodi.org/)
from a CKAN Dataset or Data.gov.uk atom feed.

# Getting started

## Clone the repo

    git clone git@github.com:theodi/certificate-generator.git
  
## Add some environment variables

* Create a file named `.env`
* Add the following you your newly-created file:

    BASE_URI='https://certificates.theodi.org/'
    ODC_USERNAME='{YOUR OPEN DATA CERTIFICATE USERNAME}'
    ODC_API_KEY='{YOUR OPEN DATA CERTIFICATE API KEY}'
		
You can get your API key from your Account page when logged into the Open Data Certificates website

If you are running your own instance of Open Data Certificates (such as on your own machine), simply replace the `BASE_URL` with the URL of the instance you want to generate certificates on.
 
## Run some commands!

To generate a single certificate from a CKAN dataset, run the following:

    rake generate:certificate URL="{CKAN dataset URL}"

To generate multiple certificates as part of a campaign run the following:

    rake generate:certificates CAMPAIGN=name URL="http://data.gov.uk/feeds/custom.atom"

This will iterate through the feed and queue up all datasets in the feed by default, if you want to limit it specify a `LIMIT` parameter like so:

    rake generate:certificates CAMPAIGN=name URL="http://data.gov.uk/feeds/custom.atom" LIMIT=2

By default it will store the links to result urls in `CAMPAIGN.csv` you can change this by specifying an `OUTPUT` parameter in case you want a descriptive campaign name but a simpler result outputfile:

    rake generate:certificates OUTPUT=output.csv CAMPAIGN=name URL="http://data.gov.uk/feeds/custom.atom" LIMIT=2

If you want to collect the results of the campaign run in a csv file then you can run:

    rake generate:results FILE=output.csv RESULTS=results.csv

Specifying the output of the `generate` task as `FILE`. This will collect the results of the import, waiting for each job to finish.
