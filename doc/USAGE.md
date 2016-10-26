# Users' Guide

## Application Forms

## Processing Applications

### Searching

Production solution for searching applications in MVP is to click on "Applications" under desired class name and use browser search function.

## Emails

The email system is designed around two entities: Templates and Rules.

### Email Templates

Templates are freely editable using a rich text editor, same that is used for interview notes. It is possible to create as many templates as desired. They may be shared between Subjects and Classes or may be common. The act of creating template doesn't change behaviour of the system. Therefore, email templates are functionally similar to MS Word documents prepared for mail merge. Templates support merge tag syntax similar to Mailchimp.

### Email Rules

Rules are a way to control when automatic emails are sent. For example:
* When Application is Applied, email Applicant with Confirmation Letter Template
* When Application is Applied, email Ad.Com. with Notification Template
* When Application is Admitted, email Applicant with Admittance Letter Template
* When Application is Shortlisted for Scholarship, email Applicant with Admittance with Scholarship Letter Template

Each Subject can be configured with different set of rules, to make backend configurable for slight differences in admissions process and email templates.

It is also possible to email any group of applicants selected by Class and Application status (for example, those who haven't paid a deposit for Class 5 yet) manually, either by selection a template or writing an email from scratch.

Each email sent is recorded in the Application History.

## Settings

### Payment Tiers

When Payment Tier is changed for a class it will apply only to applications that will be submitted after the change. New payment tier has to be applied to existing applications manually, by selecting it under Personal Detail in the application.

This may seem a bit cumbersome, but this is a failsafe feature for a situation when you already have different tiers assigned to existing applications and decide to switch default, to prevent system 'forgetting' previously selected tiers.