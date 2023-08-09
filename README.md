## CatalyxTest

## Structure

This application uses a event driven architecture, using `AWS SQS` as Queue Broker and `AWS S3` as File server

The configuration adds the action to S3 to notify when some file it's pushed to a specific repo, this notification it's
inserted to SQS with all the details and a worker verifies the message and enqueues to another worker that will insert all
data to database and then another worker will check the pending records to evaluate and creates the candle stats

> The periods are of **24 hours** so will create the candles using the whole day transactions

```
pending image
```

## How to run it

#### Pre-requisites

The application runs using Docker for containers and Maketool to create shortcuts, Docker it's for ensure the right 
version in all the local environments

- Docker with Compose
- Maketool (available by default on MacOSX and Linux systems)

Also you need insert this to your `/etc/hosts` to ensure LocalStack will work correctly

```
127.0.0.1       localstack
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## How to push file

First call to the endpoint `POST "/api/v1/get_presigned_url"` and get the url

This new url must be called using PUT using the entire file as body

#### Examples

```elixir
url = "http://localstack:4566/files/the_file_name.csv?query=params"
%{status_code: code} = HTTPoison.put!(url, {:file, "/example/path"})
```

```shell script
# using curl
curl --location --request PUT 'http://localstack:4566/files/the_file_name.csv?query=params' \
--data-binary '/home/user_default/route/to/file.csv'
```

## References

- [Processing Large CSV files with Elixir Streams](https://www.poeticoding.com/processing-large-csv-files-with-elixir-streams/)
- [Event Based System with Localstack (Elixir Edition): Uploading files to S3 with PresignedURL's](https://dev.to/nicolkill/event-based-system-with-localstack-elixir-edition-uploading-files-to-s3-with-presignedurls-5ha4)
