This project serves as a collection of frequently used analytical queries, scripts and data flow templates which are derived from common data analysis patterns I've encountered in professional settings, abstracted to be generalizable and reusable. __More sensitive client-specific information, as well as their own business tools and solutions tailored to individual client needs, are not included here.__ This repository is continuously being updated with new templates and refinements.

**About This Project**  
This project contains `SQL` queries, `DBT` models, `Python` scripts, and `Kestra` workflow files. These assets are specifically designed to illustrate common analytical methodologies and data processing practices within my working environment. All queries and `DBT` models are developed to run efficiently within a `Google Cloud Platform` environment, leveraging its robust capabilities for large-scale data processing. The content is meticulously categorized by the type of analysis or the primary tool used, ensuring clarity and ease of navigation.

*Please note: All sensitive information, proprietary data, and company-specific identifiers have been meticulously removed and abstracted to ensure strict compliance with confidentiality agreements.*

![Workflow Diagram](images/workflow.png "Workflow Diagram")

The detailed introduction of this workflow diagram please see the README.md of this repository.

**Structure and Contents**  
The project is structured to reflect different stages of data transformation and analysis, as well as specific domain applications.
- `DBT`: `DBT` models for different usecases in different tools, respecting defined layers as illustrated in the following figure:
![DBT Layers](images/dbt_layers.png "DBT Layers")
    - `Google Analytics`: Models related to web analytics data.
    - `Macros`: Reusable dbt macros for common transformations.
    - `SAP`: Models related to SAP data, which includes CDP (Customer Data Platform) related models as well.
    - `Shopify`: Models for `Shopify` e-commerce data.
- `Kestra`: The configuration of `Kestra` data flows.
- `Scripts`: `Python` scripts for different usages in the data pipeline.
- `Typical Analysis`: The custom queries/DBT models conceived for different business usecases.