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

To generate multiple certificates run the following:

		rake generate:certificates URL="http://data.gov.uk/feeds/custom.atom"

By default, this will only generate the first 20 certificates. To generate more or less, alter the `LIMIT` parameter like so:

		rake generate:certificates URL="http://data.gov.uk/feeds/custom.atom" LIMIT=2

Each run against a feed will be tagged with a campaign named with a timestamp. To add a human prefix to the campaign
name, run the following:

	rake generate:certificates URL="http://data.gov.uk/feeds/custom.atom" CAMPAIGN="dgu"
