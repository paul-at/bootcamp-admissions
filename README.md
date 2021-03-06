# README

This document outlines server setup and configuration. Please refer to the [User's Guide](doc/USAGE.md) for usage instructions.

## Installation and prerequisites

### System dependencies

This application generally behaves like a normal Rails application.

To generate automated documentation using railroady gem in development environment, [Graphviz](http://www.graphviz.org) is required.

### Configuration

Set following environment variables for production:
* `API_KEY` - shared secret to access API
* `APP_HOST` - hostname that can be used to access the application externally.
* `S3_BUCKET_NAME`
* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`
* `AWS_REGION`
* `CORS_DOMAINS` - comma-separated list of domain names (without protocol and trailing slash) that will be allowed to create applications using AJAX. For example: `a.com,b.com`.

These are the only required settings. Optionally:

Set `ALLOW_FAKER` environment variable to enable fake data generator at /setup/.

To deliver emails, configure SMTP settings from application user interface under Settings - System Settings menu using "Mail options" and "Smtp" sections.

### Running

Start the web server:

```bash
rails server
```

Optionally start email delivery process:

```bash
bundle exec rake jobs:work
```

## Application Form API

Admissions offer an API for submitting an application form. It is designed to be consumed by AJAX frontend and available as a POST endpoint at `/app_forms/` URI. The endpoint can handle multipart form for file upload and expects following request parameters:
* `app_form[klass_id]` an integer representing Class id to apply for. Required.
* `app_form[firstname]` and `app_form[lastname]` - applicant name. Required.
* `app_form[email]` - applicant email. Required.
* `app_form[phone]` - applicant phone.
* `app_form[country]` - applicant country of origin. Two-letter ISO code.
* `app_form[city]` - applicant's city and region of origin. A string.
* `app_form[residence]` - applicant current country of residence. Two-letter ISO code.
* `app_form[residence_city]` - applicant current city and region or address of residence. A string.
* `app_form[gender]` - a gender code. One uppercase character.
* `app_form[dob]` - date of birth in YYYY-MM-DD format. Can be submitted as three individual fields:
  * `app_form[dob(1i)]` - year of birth.
  * `app_form[dob(2i)]` - month of birth. An integer, January=1.
  * `app_form[dob(3i)]` - day of birth.
* `app_form[referral]` - marketing source. A string.

In addition to the closed list of parameters, any number of arbitrary string answers and file uploads can be passed. File uploads are limited to 5Mb each.

* `app_form[answers[question_name]]` answer to `question_name` question. For example: `app_form[answers[linkedin_page_url]]`.
* `app_form[uploads[kind_of_file]]` file upload that will be stored as `kind_of_file`. For example: `app_form[uploads[cv]]`.

Backend returns 200 status code on success and 422 status in case if there is a validation error. In latter case response body would be a JSON document with validation errors.

## Generate Documentation

To autogenerate state diagram run:

    bin/diagram

This will generate SVG state diagram in doc directory.

## Application Form

Steps through which an Application (AppForm) can go through are
described in [Workflow](doc/Workflow Sept 13 2016 feedback.pptx) document,
implemented in code in the [AppForm model](app/models/appform.rb) and processed to create [autogenerated state diagram](doc/states.svg).