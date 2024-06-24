## Setup Instructions

1. **Clone the Repository** 📥:
    ```sh
    git clone https://github.com/your-username/your-repository.git
    cd your-repository
    ```

2. **Configure AWS CLI** ⚙️:
    ```sh
    aws configure
    ```

3. **Initialize Terraform** 🌐:
    ```sh
    terraform init
    ```

4. **Apply Terraform Configuration** 🚀:
    ```sh
    terraform apply -auto-approve
    ```

## GitHub Actions Workflows

- **deploy.yml** 🚀: Manually triggered workflow to deploy the Strapi application.
- **stop.yml** 🛑: Manually triggered workflow to stop the Strapi application.

These workflows can be triggered from the Actions tab in your GitHub repository.
