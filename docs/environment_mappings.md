# Environment mappings

The apply service constitutes various microservices that combine to provide the functionality required. These individal services and their mapping for the various environments available are displayed in the table below.

**Table 1: Apply service microservice mapping**
| Apply      | HMRC Interface | HMRC API   | LFA        | CFE        | Portal             | CCMS       | benefits checker | provider service | govuk notify | Truelayer  | ordnance survey | govuk bank holidays |
|------------|----------------|------------|------------|------------|--------------------|------------|------------------|------------------|--------------|------------|-----------------|---------------------|
| production | production     | production | production | production | production         | production | production       | production       | prod key     | production | prod key        | production          |
| staging    | staging        | mock       | staging    | staging    | staging            | staging    | staging          | staging          | staging key  | test *     | prod key        | production          |
| UAT        | uat            | mock       | staging    | staging    | mock (can use uat) | uat        | staging          | staging          | prod key     | test *     | prod key        | production          |

\* Truelayer is a third party service that includes a testing interface with mock data

 **Table 2: Service names and descriptions**
| Service             | Description                                                                                               |
|---------------------|-----------------------------------------------------------------------------------------------------------|
| HMRC Interface      | Apply service teams API for interacting with HMRC API                                                     |
| HMRC API            | HMRC's own API for retrieving applicant details                                                           |
| LFA                 | Legal Framework API - lookup data API used by Apply                                                       |
| CFE                 | Check Financial Eligibility - API to determine whether applicant can receive Legal Aid and to what extent |
| Portal              | "Single Sign-on solution used for Apply authentication process, amongst others"                           |
| CCMS                | Legacy system to which applications are sent for processing by case workers                               |
| Benefit Checker     | Department for Work and Pensions API used to check applicant's receipt of benefits                        |
| Provider service    | Check provider details                                                                                    |
| Gov UK notify       | Email service provider                                                                                    |
| Truelayer           | Open banking API used to retrieve bank statement of applicants                                            |
| Ordnance survey     | Address lookup API                                                                                        |
| Govuk Bank holidays | Bank holiday lookup API                                                                                   |
