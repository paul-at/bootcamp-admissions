# Bulk Data Import

The admissions application has ability to import Application Forms in bulk.

The input format is a standard CSV file, headers of which will be processed differently depending on a name.

## Personal Information Columns

The following fields will be imported as personal information fields:
* firstname
* lastname
* email
* country
* residence
  Country and residence fields have to be either two-letter ISO country codes, otherwise a guess will be made to determine which country code the country in question has and if failed first two characters will be converted to upper case and used as a country code.
* gender
  One-letter gender code.
* dob
* referral
* paid
* city
* residence_city
* phone

## Special Columns

* aasm_state
  One of the [state names](states.svg) supported by the application.
* updated_at
  Date when the application has been updated.
* created_at
  Date when the application has been created.

## Arbitrary Columns

All remaining columns will be imported as answers to survey questions.