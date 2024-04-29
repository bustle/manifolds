# Manifolds

Manifolds is an innovative open-source framework designed to streamline the process of generating and managing sophisticated data infrastructures in Google BigQuery using Terraform. By leveraging Manifolds, teams can efficiently create complex views that join dimensional data with multiple metrics tables, enabling deeper insights and more dynamic data interactions.

## Philosophy

At the heart of Manifolds, our philosophy is to simplify the complexity inherent in managing large-scale data architectures. We aim to provide a tool that not only facilitates the easy setup of data structures but also adheres to best practices in scalability, maintainability, and performance. Manifolds is built for data engineers, by data engineers, ensuring that the nuances and common challenges in data management are well-addressed.

## Features

- **Unified Data Modeling**: Manifolds introduces a standardized way to model dimensions and metrics, ensuring consistency and reliability in data reporting and analysis.
- **Scalability**: Designed to handle large volumes of data, supporting a variety of data types and structures.
- **Flexibility**: Easily adapt to different kinds of metric groupings such as by device type (e.g., desktop, tablet, mobile) with identical metric structures beneath these segmentations.

## Getting Started

### Prerequisites

- Ruby
- Terraform
- Google Cloud SDK (gcloud)

### Installation

1. **Clone the repository**:

```bash
git clone https://github.com/bustle/manifolds.git
cd manifolds
```

2. **Setup Terraform**: Ensure that Terraform is installed and configured to interact with your Google Cloud Platform account.

3. **Configure Your Environment**: Set up your environment variables and credentials to access Google BigQuery and other necessary services.

## Contributing

We welcome contributions from the community! Please check out our [contribution guidelines](docs/CONTRIBUTING.md) for more information on how to get involved.

## License

Distributed under the MIT License. See LICENSE for more information
