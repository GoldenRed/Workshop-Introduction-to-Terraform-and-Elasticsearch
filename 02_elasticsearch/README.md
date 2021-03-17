# Elasticsearch

## Create ES Domain
Running `terraform init` and then `terraform apply` will deploy an Elasticsearchdomain on AWS, in the eu-north-1 region by default.

It can take some time until the ES domain is ready, but once that has happened Terraform will output the domain endpoint URL for you.

## Load data

Run `curl -H "Content-type: application/json" -XPOST "[insert domain endpoint url here]/_bulk?pretty" --data-binary "@data/sample_movies.json"`

ES has an api endpoint you can use to do bulk import of data into, and we are using it here to upload the sample_movies.json data.

